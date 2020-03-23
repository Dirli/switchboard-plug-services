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
        private Gtk.TreeSelection tree_selection;

        private Gtk.Switch service_switcher;
        private Gtk.Box bottom_box;
        private Gtk.Button run_button;
        private Gtk.Button restart_button;
        private Gtk.Button stop_button;
        private Widgets.ServicesView view;

        private string active_service = "";

        public bool permission {
            set {
                bottom_box.visible = value;
            }
        }

        public MainView () {
            orientation = Gtk.Orientation.VERTICAL;
            row_spacing = 12;
            margin = 12;

            list_store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (string));

            view = new Widgets.ServicesView ();
            view.set_model (list_store);
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

            run_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            run_button.tooltip_text = _("Run service");
            run_button.sensitive = false;
            run_button.clicked.connect (() => {
                clicked_button ("start");
            });

            restart_button = new Gtk.Button.from_icon_name ("system-reboot-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            restart_button.tooltip_text = _("Restart service");
            restart_button.sensitive = false;
            restart_button.clicked.connect (() => {
                clicked_button ("restart");
            });

            stop_button = new Gtk.Button.from_icon_name ("media-playback-stop-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            stop_button.tooltip_text = _("Stop service");
            stop_button.sensitive = false;
            stop_button.clicked.connect (() => {
                clicked_button ("stop");
            });

            var btns_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            btns_box.add (run_button);
            btns_box.add (restart_button);
            btns_box.add (stop_button);

            var switch_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            switch_box.add (switcher_label);
            switch_box.add (service_switcher);

            bottom_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            bottom_box.pack_start (btns_box, false);
            bottom_box.pack_end (switch_box, false);

            var frame = new Gtk.Frame (null);
            frame.add (scrolled);

            add (frame);
            add (bottom_box);

            load_services ();
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
                    list_store.insert_with_values (out iter, -1,
                                                   0, service_name,
                                                   1, service_state,
                                                   2, service_active,
                                                   3, service_description, -1);

                    return true;
                });

                return null;
            });
        }

        private void clicked_button (string command_name) {
            if (active_service == "") {
                return;
            }

            Utils.exec_command (command_name, active_service);

            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            if (tree_selection.get_selected (out model, out iter)) {
                var s_active = Utils.get_service_property (active_service, "ActiveState");
                var sub = Utils.get_service_property (active_service, "SubState");

                run_button.sensitive = s_active != "active";
                restart_button.sensitive = s_active == "active";
                stop_button.sensitive = s_active == "active";

                s_active = s_active + " (" + sub + ")";

                (model as Gtk.ListStore).@set (iter, 2, s_active, -1);
            }
        }

        private void change_start_state () {
            if (active_service == "") {
                return;
            }

            Utils.exec_command (service_switcher.active ? "enable" : "disable", active_service);


            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            if (tree_selection.get_selected (out model, out iter)) {
                var service_state = Utils.get_service_property (active_service, "UnitFileState");
                (model as Gtk.ListStore).@set (iter, 1, service_state, -1);
            }
        }

        private void selected_item_changed () {
            service_switcher.notify["active"].disconnect (change_start_state);
            Gtk.TreeModel model;
            Gtk.TreeIter iter;

            active_service = "";

            if (tree_selection.get_selected (out model, out iter)) {
                string start_state;
                string s_name;
                model.@get (iter, 0, out s_name, 1, out start_state, -1);

                if (start_state != "static") {
                    service_switcher.active = start_state == "enabled";
                }
                service_switcher.sensitive = start_state != "static";

                var active_state = Utils.get_service_property (s_name, "ActiveState");
                run_button.sensitive = active_state != "active";
                restart_button.sensitive = active_state == "active";
                stop_button.sensitive = active_state == "active";

                active_service = s_name;
                service_switcher.notify["active"].connect (change_start_state);
            }
        }

        private void on_row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            if (tree_selection.get_selected (out model, out iter)) {
                string s_name;
                model.@get (iter, 0, out s_name, -1);

                var s_status = Utils.get_service_status (s_name);

                new Widgets.ServiceStatus ((Gtk.Window) get_toplevel (), s_name, s_status);
            }
        }
    }
}
