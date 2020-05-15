namespace Services {
    public class Widgets.FilterBox : Gtk.Box {
        public signal void changed_filter (int filter_column, string filter_value);

        private string current_filter;

        private Gtk.SearchEntry search_entry;
        private Gtk.Stack stack;

        public FilterBox () {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    spacing: 10,
                    margin: 12,
                    valign: Gtk.Align.CENTER,
                    halign: Gtk.Align.CENTER);

            search_entry = new Gtk.SearchEntry ();
            search_entry.valign = Gtk.Align.CENTER;
            search_entry.placeholder_text = _("Search Service");
            search_entry.search_changed.connect (() => {
                if (search_entry.text_length < 3) {
                    changed_filter (0, "");
                    return;
                }

                changed_filter (0, search_entry.text);
            });

            var state_combo = new Gtk.ComboBoxText ();
            state_combo.halign = Gtk.Align.FILL;
            state_combo.append ("", "");
            state_combo.append ("enabled", _("enabled"));
            state_combo.append ("enabled-runtime", _("enabled-runtime"));
            state_combo.append ("linked", _("linked"));
            state_combo.append ("linked-runtime", _("linked-runtime"));
            state_combo.append ("masked", _("masked"));
            state_combo.append ("masked-runtime", _("masked-runtime"));
            state_combo.append ("static", _("static"));
            state_combo.append ("indirect", _("indirect"));
            state_combo.append ("disabled", _("disabled"));
            state_combo.append ("generated", _("generated"));
            state_combo.append ("transient", _("transient"));
            state_combo.append ("bad", _("bad"));

            stack = new Gtk.Stack ();
            stack.add_titled (search_entry, "service", _("Service"));
            stack.add_titled (state_combo, "state", _("State"));

            current_filter = "service";

            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.halign = Gtk.Align.CENTER;
            stack_switcher.homogeneous = true;
            stack_switcher.stack = stack;

            add (stack_switcher);
            add (stack);

            show_all ();

            state_combo.changed.connect (() => {
                changed_filter (1, state_combo.get_active_id ());
            });

            GLib.Idle.add (() => {
                stack.notify["visible-child"].connect (() => {
                    clear_filter ();
                });

                return false;
            });
        }

        public void clear_filter () {
            if (current_filter != null) {
                var w = stack.get_child_by_name (current_filter);
                if (w == null) {
                    return;
                }

                if (w is Gtk.SearchEntry) {
                    var search_widget = w as Gtk.SearchEntry;
                    if (search_widget.text_length > 2) {
                        search_widget.text = "";
                    }
                } else if (w is Gtk.ComboBoxText) {
                    var combo_widget = w as Gtk.ComboBoxText;
                    if (combo_widget.get_active () > 0) {
                        combo_widget.set_active (0);
                    }
                }
            }

            current_filter = stack.get_visible_child_name ();
        }
    }
}
