namespace Services {
    public class Widgets.ServicesView : Gtk.TreeView {
        public ServicesView () {
            set_headers_clickable (false);
            headers_visible = true;
            activate_on_single_click = false;
            margin = 12;

            get_selection ().set_mode (Gtk.SelectionMode.SINGLE);

            add_column (create_column (_("Service"), 0));
            add_column (create_column (_("Start"), 1));
            add_column (create_column (_("State"), 2));
            add_column (create_column (_("Description"), 3));
        }

        public void add_column (Gtk.TreeViewColumn column) {
            column.sizing = Gtk.TreeViewColumnSizing.FIXED;

            // string test_strings = "";

            Gtk.CellRenderer? renderer = null;

            renderer = new Gtk.CellRendererText ();
            column.set_cell_data_func (renderer, cell_data_func);


            column.pack_start (renderer, true);
            insert_column (column, -1);

            // var text_renderer = renderer as Gtk.CellRendererText;
            // if (text_renderer != null) {
            //     set_fixed_column_width (this, column, text_renderer, test_strings, 5);
            // }

            column.reorderable = false;
            column.clickable = true;
            column.resizable = true;
            column.expand = true;
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
            // column.set_data<int> (Constants.TYPE_DATA_KEY, 0);
            column.title = title;
            column.sort_column_id = cid;
            column.visible = true;

            return column;
        }

        // private void set_fixed_column_width (Gtk.Widget treeview, Gtk.TreeViewColumn column, Gtk.CellRendererText renderer, string strings, int padding) {
        //     int max_width = 0;
        //
        //     renderer.text = strings;
        //     Gtk.Requisition natural_size;
        //     renderer.get_preferred_size (treeview, null, out natural_size);
        //
        //     if (natural_size.width > max_width) {
        //         max_width = natural_size.width;
        //     }
        //
        //     column.fixed_width = max_width + padding;
        // }

        public inline void cell_data_func (Gtk.CellLayout layout, Gtk.CellRenderer cell, Gtk.TreeModel tree_model, Gtk.TreeIter iter) {
            if ((tree_model as Gtk.ListStore).iter_is_valid (iter)) {
                Gtk.TreeIter i = iter;
                var tvc = layout as Gtk.TreeViewColumn;
                GLib.return_if_fail (tvc != null);

                int column = tvc.sort_column_id;
                if (column < 0) {
                    return;
                }

                GLib.Value val;
                tree_model.get_value (i, column, out val);
                (cell as Gtk.CellRendererText).text = val.get_string ();
            }
        }
    }
}
