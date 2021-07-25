/*
 * Copyright (c) 2020-2021 Dirli <litandrej85@gmail.com>
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
    public class Widgets.ServiceStatus : Gtk.Dialog {
        public string service_info { get; construct set;}

        public ServiceStatus (Gtk.Window parent, string s_name, string status) {
            Object (border_width: 6,
                    deletable: false,
                    destroy_with_parent: true,
                    resizable: false,
                    service_info: status,
                    title: s_name,
                    transient_for: parent,
                    width_request: 540,
                    window_position: Gtk.WindowPosition.CENTER_ON_PARENT);
        }

        construct {
            var status_label = new Gtk.Label (service_info);
            status_label.margin = 10;

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.add (status_label);
            scrolled.expand = true;
            scrolled.vscrollbar_policy = Gtk.PolicyType.NEVER;

            var frame = new Gtk.Frame (null);
            frame.add (scrolled);

            var content = get_content_area () as Gtk.Box;
            content.add (frame);

            var close_button = add_button (_("Close"), Gtk.ResponseType.CLOSE);
            ((Gtk.Button) close_button).clicked.connect (() => {
                destroy ();
            });
        }
    }
}
