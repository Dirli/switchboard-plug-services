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

            var clear_button = new Gtk.Button.from_icon_name ("edit-clear-symbolic-rtl", Gtk.IconSize.MENU);
            clear_button.tooltip_text = _("Clear filter");
            clear_button.sensitive = false;

            var filter_box = new Widgets.FilterBox ();
            filter_box.changed_filter.connect ((col, val) => {
                clear_button.sensitive = val != "";
                main_view.run_filter (col, val);
            });

            clear_button.clicked.connect (() => {
                filter_box.clear_filter ();
            });

            var filter_popover = new Gtk.Popover (null);
            filter_popover.add (filter_box);

            var filter_button = new Gtk.MenuButton ();
            filter_button.tooltip_text = _("Filters");
            filter_button.image = new Gtk.Image.from_icon_name ("view-filter-symbolic", Gtk.IconSize.MENU);
            filter_button.popover = filter_popover;

            var help_box = new Widgets.HelpBox ();

            var help_popover = new Gtk.Popover (null);
            help_popover.add (help_box);

            var help_button = new Gtk.MenuButton ();
            help_button.image = new Gtk.Image.from_icon_name ("system-help-symbolic", Gtk.IconSize.MENU);
            help_button.popover = help_popover;

            var unlock_image = new Gtk.Image.from_icon_name ("changes-allow-symbolic", Gtk.IconSize.MENU);

            var buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            buttons_box.margin = 12;
            buttons_box.margin_bottom = 0;
            buttons_box.pack_start (help_button, false);
            buttons_box.pack_start (unlock_image, false);
            buttons_box.pack_end (filter_button, false);
            buttons_box.pack_end (clear_button, false);

            main_grid = new Gtk.Grid ();
            main_grid.attach (buttons_box, 0, 0);
            main_grid.attach (main_view, 0, 1);

            main_grid.show_all ();

            var permission = Utils.get_permission ();
            permission.notify["allowed"].connect (() => {
                unlock_image.visible = permission.allowed;
            });
            unlock_image.visible = permission.allowed;

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
