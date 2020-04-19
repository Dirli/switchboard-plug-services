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
    public class Widgets.WaitingView : Gtk.Box {
        private Gtk.Spinner spinner;
        public WaitingView () {
            Object (orientation: Gtk.Orientation.HORIZONTAL,
                    spacing: 10,
                    valign: Gtk.Align.CENTER,
                    halign: Gtk.Align.CENTER);
        }

        construct {
            spinner = new Gtk.Spinner ();

            add (spinner);
            add (new Gtk.Label (_("Loading services...")));

            get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

            show_all ();
        }

        public void start_spinner (bool start) {
            if (start) {
                spinner.start ();
            } else {
                spinner.stop ();
            }
        }
    }
}
