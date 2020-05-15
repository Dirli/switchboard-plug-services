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
    public class Widgets.ServicesView : Gtk.TreeView {
        public ServicesView () {
            set_headers_clickable (false);
            headers_visible = true;
            activate_on_single_click = false;
            margin = 12;

            get_selection ().set_mode (Gtk.SelectionMode.SINGLE);

            add_column (create_column (_("Service"), 0));
            add_column (create_column (_("State"), 1), "enabled-runtime");
            add_column (create_column (_("Active"), 2), "active (running)");
            add_column (create_column (_("Description"), 3));
        }

        public void add_column (Gtk.TreeViewColumn column, string? test_string = null) {
            column.sizing = Gtk.TreeViewColumnSizing.FIXED;

            Gtk.CellRenderer? renderer = null;

            renderer = new Gtk.CellRendererText ();
            column.set_cell_data_func (renderer, cell_data_func);


            column.pack_start (renderer, true);
            insert_column (column, -1);

            var text_renderer = renderer as Gtk.CellRendererText;
            if (test_string != null && text_renderer != null) {
                set_fixed_column_width (this, column, text_renderer, test_string, 8);
            }

            column.reorderable = false;
            column.clickable = true;
            column.resizable = test_string == null;
            column.expand = test_string == null;
            column.sort_indicator = false;

            var header_button = column.get_button ();

            if (headers_visible) {
                Gtk.Requisition natural_size;
                header_button.get_preferred_size (null, out natural_size);

                if (natural_size.width > column.fixed_width) {
                    column.fixed_width = natural_size.width;
                }
            }

            column.min_width = column.fixed_width;
        }

        private Gtk.TreeViewColumn create_column (string title, int cid ) {
            var column = new Gtk.TreeViewColumn ();
            column.title = title;
            column.sort_column_id = cid;
            column.visible = true;

            return column;
        }

        private void set_fixed_column_width (Gtk.Widget treeview, Gtk.TreeViewColumn column, Gtk.CellRendererText renderer, string test_string, int padding) {
            int max_width = 0;

            renderer.text = test_string;
            Gtk.Requisition natural_size;
            renderer.get_preferred_size (treeview, null, out natural_size);

            if (natural_size.width > max_width) {
                max_width = natural_size.width;
            }

            column.fixed_width = max_width + padding;
        }

        public inline void cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer cell, Gtk.TreeModel tree_model, Gtk.TreeIter iter) {
            Gtk.TreeIter i = iter;
            var tvc = layout as Gtk.TreeViewColumn;
            GLib.return_if_fail (tvc != null);

            int column = tvc.sort_column_id;
            if (column < 0) {
                return;
            }

            var cell_text = cell as Gtk.CellRendererText;
            if (cell_text == null) {
                return;
            }

            GLib.Value val;
            tree_model.get_value (i, column, out val);
            cell_text.text = val.get_string ();
        }
    }
}
