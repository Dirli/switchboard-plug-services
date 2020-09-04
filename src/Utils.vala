/*
 * Copyright (c) 2020 Dirli <litandrej85@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace Services.Utils {
    private static Polkit.Permission? permission = null;
    public static Polkit.Permission? get_permission () {
        if (permission != null) {
            return permission;
        }

        try {
            permission = new Polkit.Permission.sync ("io.elementary.switchboard.services.administration", new Polkit.UnixProcess (Posix.getpid ()));
            return permission;
        } catch (Error e) {
            critical (e.message);
            return null;
        }
    }

    public struct Unit {
        public string title;
        public string state;
        public bool load;
        public string active;
        public string sub;
        public string description;
    }

    public static string get_service_status (string service_name) {
        try {
            string ls_stdout;
            GLib.Process.spawn_command_line_sync ("systemctl status %s".printf (service_name), out ls_stdout, null, null);
            return ls_stdout;
        } catch (Error e) {
            warning (e.message);
        }

        return "";
    }

    public static string get_service_property (string service_name, string service_property) {
        try {
            string ls_stdout;
            GLib.Process.spawn_command_line_sync ("systemctl show --property=%s %s".printf (service_property, service_name), out ls_stdout, null, null);
            var prop = ls_stdout.split ("=", 2);
            if (prop.length == 2) {
                return prop[1].strip ();
            }
        } catch (Error e) {
            warning (e.message);
        }

        return "";
    }

    public static int sort_func (string a, string b) {
        return strcmp (a.collate_key (), b.collate_key ());
    }

    public static void exec_command (string command, string service_name) {
        try {
            GLib.Process.spawn_command_line_sync ("pkexec /usr/bin/io.elementary.switchboard.services.helper -c %s -s %s".printf (command, service_name), null, null, null);
        } catch (Error e) {
            warning (e.message);
        }
    }

    public static Gee.TreeMap<string, Unit?> get_services () {
        var services = new Gee.TreeMap<string, Unit?> (sort_func);
        string ls_stdout;
        string opts = " --no-legend --no-pager --no-ask-password";

        try {
            GLib.Process.spawn_command_line_sync ("systemctl list-unit-files --type service" + opts, out ls_stdout, null, null);
            string[] services_arr = ls_stdout.split ("\n");

            foreach (var s in services_arr) {
                var s_arr = s.split (" ", 2);
                if (s_arr.length > 1) {
                    var full_name = s_arr[0];
                    var service_state = s_arr[1].strip ();
                    s_arr = service_state.split (" ", 2);
                    service_state = s_arr[0].strip ();
                    if (service_state != "masked") {
                        var service_name = full_name.slice (0, full_name.index_of (".service"));
                        if (!service_name.has_suffix ("@")) {
                            if (!services.has_key (service_name)) {
                                Unit service = {};
                                service.title = service_name;
                                service.state = service_state;
                                services[service_name] = service;
                            }
                        }
                    }
                }
            }

            GLib.Process.spawn_command_line_sync ("systemctl list-units --all --type service" + opts, out ls_stdout, null, null);

            string[] services_arr1 = ls_stdout.split ("\n");
            foreach (var s in services_arr1) {
                var s_arr = s.strip ().split (" ", 2);
                while (s_arr.length > 1 && !s_arr[0].get_char ().isalpha ()) {
                    s_arr = s_arr[1].strip ().split (" ", 2);
                }

                if (s_arr.length < 2 || !s_arr[0].get_char ().isalpha ()) {
                    continue;
                }

                var full_name = s_arr[0];
                var service_name = full_name.slice (0, full_name.index_of (".service"));

                var service_str = s_arr[1].strip ();
                s_arr = service_str.split (" ", 2);
                var service_load = s_arr[0];

                if (service_load != "not-found") {
                    service_str = s_arr[1].strip ();
                    s_arr = service_str.split (" ", 2);
                    var service_active = s_arr[0];

                    service_str = s_arr[1].strip ();
                    s_arr = service_str.split (" ", 2);
                    var service_sub = s_arr[0];
                    var description = s_arr[1].strip ();
                    if (services.has_key (service_name)) {
                        var unit = services[service_name];
                        unit.description = description;
                        unit.active = service_active;
                        unit.sub = service_sub;
                    } else {
                        Unit service = {};
                        service.title = service_name;
                        service.description = description;
                        service.active = service_active;
                        service.sub = service_sub;
                        services[service_name] = service;
                    }
                }
            }

        } catch (Error e) {
            warning (e.message);
        }

        return services;
    }
}
