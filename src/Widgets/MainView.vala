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

namespace Services {
    public class Widgets.MainView : Gtk.Grid {
        private Gtk.ListStore list_store;
        private Gtk.TreeModelFilter list_filter;
        private Gtk.TreeSelection tree_selection;

        private Widgets.WaitingView waiting_box;

        private Gtk.Stack stack;
        private Gtk.Switch service_switcher;
        private Gtk.Button run_button;
        private Gtk.Button restart_button;
        private Gtk.Button stop_button;
        private Widgets.ServicesView view;

        private int filter_column;
        private string filter_value = "";

        private bool actual_active;
        private string active_service = "";

        public MainView () {
            orientation = Gtk.Orientation.VERTICAL;
            row_spacing = 12;
            margin = 12;

            waiting_box = new Widgets.WaitingView ();
            waiting_box.start_spinner (true);

            list_store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (string));

            list_filter = new Gtk.TreeModelFilter (list_store, null);
            list_filter.set_visible_func (row_visible);

            view = new Widgets.ServicesView ();
            view.row_activated.connect (on_row_activated);
            tree_selection = view.get_selection ();
            tree_selection.changed.connect (selected_item_changed);

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.add (view);
            scrolled.expand = true;

            var switcher_label = new Gtk.Label (_("Enable/Disable service:"));

            service_switcher = new Gtk.Switch ();
            service_switcher.valign = Gtk.Align.CENTER;
            service_switcher.sensitive = false;

            run_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
            run_button.tooltip_text = _("Run service");
            run_button.sensitive = false;
            run_button.clicked.connect (() => {
                var permission = Utils.get_permission ();
                if (!permission.allowed) {
                    try {
                        permission.acquire ();
                    } catch (Error e) {
                        return;
                    }
                }
                clicked_button ("start");
            });

            restart_button = new Gtk.Button.from_icon_name ("system-reboot-symbolic", Gtk.IconSize.MENU);
            restart_button.tooltip_text = _("Restart service");
            restart_button.sensitive = false;
            restart_button.clicked.connect (() => {
                var permission = Utils.get_permission ();
                if (!permission.allowed) {
                    try {
                        permission.acquire ();
                    } catch (Error e) {
                        return;
                    }
                }

                clicked_button ("restart");
            });

            stop_button = new Gtk.Button.from_icon_name ("media-playback-stop-symbolic", Gtk.IconSize.MENU);
            stop_button.tooltip_text = _("Stop service");
            stop_button.sensitive = false;
            stop_button.clicked.connect (() => {
                var permission = Utils.get_permission ();
                if (!permission.allowed) {
                    try {
                        permission.acquire ();
                    } catch (Error e) {
                        return;
                    }
                }

                clicked_button ("stop");
            });

            var btns_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            btns_box.add (stop_button);
            btns_box.add (run_button);
            btns_box.add (restart_button);

            var switch_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            switch_box.add (switcher_label);
            switch_box.add (service_switcher);

            var bottom_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            bottom_box.pack_start (btns_box, false);
            bottom_box.pack_end (switch_box, false);

            stack = new Gtk.Stack ();
            stack.add_named (scrolled, "mainview");
            stack.add_named (waiting_box, "waiting");
            stack.set_visible_child_name ("waiting");

            var frame = new Gtk.Frame (null);
            frame.add (stack);

            add (frame);
            add (bottom_box);

            load_services ();
        }

        private bool row_visible (Gtk.TreeModel model, Gtk.TreeIter iter) {
            if (filter_value == "") {
                return true;
            }

            switch (filter_column) {
                case 0:
                    string s_name;
                    list_store.@get (iter, 0, out s_name, -1);
                    return s_name.index_of (filter_value) >= 0;
                case 1:
                    string start_state;
                    list_store.@get (iter, 1, out start_state, -1);
                    return start_state == filter_value;
            }

            return true;
        }

        private void load_services () {
            new Thread<void*> ("load_services", () => {
                var units = Utils.get_services ();
                units.ascending_keys.foreach ((k) => {
                    var service = units[k];
                    var service_name = service.title;
                    var service_state = service.state;
                    if (service_state == null) {
                        service_state = Utils.get_service_property (service_name, "UnitFileState");
                    }

                    var service_description = service.description;
                    if (service_description == null) {
                        service_description = Utils.get_service_property (service_name, "Description");
                    }

                    var service_active = service.active;
                    if (service_active == null) {
                        service_active = Utils.get_service_property (service_name, "ActiveState");
                    }

                    var service_sub = service.sub;
                    if (service_sub == null) {
                        service_sub = Utils.get_service_property (service_name, "SubState");
                    }

                    service_active = service_active + " (" + service_sub + ")";

                    Gtk.TreeIter iter;
                    list_store.append (out iter);
                    list_store.@set (iter,
                                     0, service_name,
                                     1, service_state,
                                     2, service_active,
                                     3, service_description, -1);

                    return true;
                });

                view.set_model (list_filter);

                waiting_box.start_spinner (false);
                stack.set_visible_child_name ("mainview");
                return null;
            });
        }

        public void run_filter (int col, string val) {
            filter_value = val;
            filter_column = col;

            list_filter.refilter ();
        }

        private void clicked_button (string command_name) {
            if (active_service == "") {
                return;
            }

            Utils.exec_command (command_name, active_service);

            Gtk.TreeModel model;
            Gtk.TreeIter filter_iter;
            if (tree_selection.get_selected (out model, out filter_iter)) {
                Gtk.TreeIter iter;
                list_filter.convert_iter_to_child_iter (out iter, filter_iter);

                var s_active = Utils.get_service_property (active_service, "ActiveState");
                var sub = Utils.get_service_property (active_service, "SubState");

                run_button.sensitive = s_active != "active";
                restart_button.sensitive = s_active == "active";
                stop_button.sensitive = s_active == "active";

                s_active = s_active + " (" + sub + ")";
                list_store.@set (iter, 2, s_active, -1);
            }
        }

        private void change_start_state () {
            if (actual_active == service_switcher.active || active_service == "") {
                return;
            }

            var permission = Utils.get_permission ();
            if (!permission.allowed) {
                try {
                    permission.acquire ();
                } catch (Error e) {
                    service_switcher.active = actual_active;
                    return;
                }
            }

            actual_active = service_switcher.active;

            Utils.exec_command (service_switcher.active ? "enable" : "disable", active_service);

            Gtk.TreeModel model;
            Gtk.TreeIter filter_iter;
            if (tree_selection.get_selected (out model, out filter_iter)) {
                Gtk.TreeIter iter;
                list_filter.convert_iter_to_child_iter (out iter, filter_iter);

                var service_state = Utils.get_service_property (active_service, "UnitFileState");
                list_store.@set (iter, 1, service_state, -1);
            }
        }

        private void selected_item_changed () {
            service_switcher.notify["active"].disconnect (change_start_state);
            Gtk.TreeModel model;
            Gtk.TreeIter filter_iter;

            active_service = "";

            if (tree_selection.get_selected (out model, out filter_iter)) {
                Gtk.TreeIter iter;
                list_filter.convert_iter_to_child_iter (out iter, filter_iter);

                string start_state;
                string s_name;
                list_store.@get (iter, 0, out s_name, 1, out start_state, -1);

                service_switcher.sensitive = start_state == "enabled" || start_state == "disabled";
                if (service_switcher.sensitive) {
                    service_switcher.active = start_state == "enabled";
                    actual_active = service_switcher.active;
                }

                var active_state = Utils.get_service_property (s_name, "ActiveState");
                run_button.sensitive = active_state != "active";
                restart_button.sensitive = active_state == "active";
                stop_button.sensitive = active_state == "active";

                active_service = s_name;
            }

            service_switcher.notify["active"].connect (change_start_state);
        }

        private void on_row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
            Gtk.TreeModel model;
            Gtk.TreeIter filter_iter;
            if (tree_selection.get_selected (out model, out filter_iter)) {
                Gtk.TreeIter iter;
                list_filter.convert_iter_to_child_iter (out iter, filter_iter);

                string s_name;
                list_store.@get (iter, 0, out s_name, -1);

                var s_status = Utils.get_service_status (s_name);

                new Widgets.ServiceStatus ((Gtk.Window) get_toplevel (), s_name, s_status);
            }
        }
    }
}
