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
    public class ServicesPlug : Switchboard.Plug {
        private Gtk.Grid main_grid;

        public ServicesPlug () {
            var settings = new Gee.TreeMap<string, string?> (null, null);
            settings.set ("Services", null);
            Object (category: Category.SYSTEM,
                    code_name: "io.elementary.switchboard.services",
                    display_name: _("Services"),
                    description: _("Manage services"),
                    icon: "preferences-system",
                    supported_settings: settings);
        }

        public override Gtk.Widget get_widget () {
            if (main_grid != null) {
                return main_grid;
            }

            var main_view = new Widgets.MainView ();

            var info_bar = new Gtk.InfoBar ();
            info_bar.message_type = Gtk.MessageType.INFO;

            var permission = Utils.get_permission ();
            var lock_button = new Gtk.LockButton (permission);

            var area = info_bar.get_action_area () as Gtk.Container;
            area.add (lock_button);

            var content = info_bar.get_content_area ();
            content.add (new Gtk.Label (_("You must have administrator rights to manage the services")));

            main_grid = new Gtk.Grid ();
            main_grid.margin = 6;

            main_grid.attach (info_bar, 0, 0, 1, 1);
            main_grid.attach (main_view, 0, 1, 1, 1);

            main_grid.show_all ();

            permission.notify["allowed"].connect (() => {
                info_bar.visible = !permission.allowed;
                main_view.permission = permission.allowed;
            });
            main_view.permission = permission.allowed;

            return main_grid;
        }

        public override void shown () {}

        public override void hidden () {}

        public override void search_callback (string location) {}

        public override async Gee.TreeMap<string, string> search (string search) {
            var search_results = new Gee.TreeMap<string, string> ((GLib.CompareDataFunc<string>) strcmp, (Gee.EqualDataFunc<string>) str_equal);

            return search_results;
        }
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Services plug");
    var plug = new Services.ServicesPlug ();
    return plug;
}
