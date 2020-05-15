namespace Services {
    public class Widgets.HelpBox : Gtk.Box {
        public HelpBox () {
            Object (orientation: Gtk.Orientation.VERTICAL,
                    spacing: 10,
                    margin: 12,
                    height_request: 420,
                    width_request: 675);
        }

        construct {
            var state_grid = new Gtk.Grid ();
            state_grid.column_spacing = 8;
            state_grid.row_spacing = 12;

            int i = 0;
            add_help_iter (state_grid, i++, "enabled\n[-runtime]", _("Enabled via .wants/, .requires/ or Alias= symlinks (permanently in /etc/systemd/system/, or transiently in /run/systemd/system/)."));
            add_help_iter (state_grid, i++, "linked\n[-runtime]", _("Made available through one or more symlinks to the unit file (permanently in /etc/systemd/system/ or transiently in /run/systemd/system/), even though the unit file might reside outside of the unit file search path."));
            add_help_iter (state_grid, i++, "masked\n[-runtime]", _("Completely disabled, so that any start operation on it fails (permanently in /etc/systemd/system/ or transiently in /run/systemd/systemd/)"));
            add_help_iter (state_grid, i++, "static", _("The unit file is not enabled, and has no provisions for enabling in the \"[Install]\" unit file section."));
            add_help_iter (state_grid, i++, "indirect", _("The unit file itself is not enabled, but it has a non-empty Also= setting in the \"[Install]\" unit file section, listing other unit files that might be enabled, or it has an alias under a different name through a symlink that is not specified in Also=. For template unit file, an instance different than the one specified in DefaultInstance= is enabled."));
            add_help_iter (state_grid, i++, "disabled", _("The unit file is not enabled, but contains an \"[Install]\" section with installation instructions."));
            add_help_iter (state_grid, i++, "generated", _("The unit file was generated dynamically via a generator tool. See systemd.generator(7). Generated unit files may not be enabled, they are enabled implicitly by their generator."));
            add_help_iter (state_grid, i++, "transient", _("The unit file has been created dynamically with the runtime API. Transient units may not be enabled."));
            add_help_iter (state_grid, i++, "bad", _("The unit file is invalid or another error occurred. Note that is-enabled will not actually return this state, but print an error message instead. However the unit file listing printed by list-unit-files might show it."));

            Gtk.ScrolledWindow state_window = new Gtk.ScrolledWindow (null, null);
            state_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
            state_window.expand = true;
            state_window.margin = 12;
            state_window.add (state_grid);

            var active_grid = new Gtk.Grid ();
            active_grid.column_spacing = 8;
            active_grid.row_spacing = 12;

            i = 0;
            add_help_iter (active_grid, i++, "initializing", _("Early bootup, before basic.target is reached or the maintenance state entered."));
            add_help_iter (active_grid, i++, "starting", _("Late bootup, before the job queue becomes idle for the first time, or one of the rescue targets are reached."));
            add_help_iter (active_grid, i++, "running", _("The system is fully operational."));
            add_help_iter (active_grid, i++, "degraded", _("The system is operational but one or more units failed."));
            add_help_iter (active_grid, i++, "maintenance", _("The rescue or emergency target is active."));
            add_help_iter (active_grid, i++, "stopping", _("The manager is shutting down."));
            add_help_iter (active_grid, i++, "offline", _("The manager is not running. Specifically, this is the operational state if an incompatible program is running as system manager (PID 1)."));
            add_help_iter (active_grid, i++, "unknown", _("The operational state could not be determined, due to lack of resources or another error cause."));

            Gtk.ScrolledWindow active_window = new Gtk.ScrolledWindow (null, null);
            active_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
            active_window.expand = true;
            active_window.margin = 12;
            active_window.add (active_grid);

            var stack = new Gtk.Stack ();
            stack.add_titled (state_window, "state", _("State"));
            stack.add_titled (active_window, "active", _("Active"));

            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.halign = Gtk.Align.CENTER;
            stack_switcher.homogeneous = true;
            stack_switcher.stack = stack;

            var more_label = new Gtk.LinkButton.with_label (
                "https://www.freedesktop.org/software/systemd/man/systemctl.html",
                _("learn more")
            );
            more_label.halign = Gtk.Align.CENTER;

            add (stack_switcher);
            add (stack);
            add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
            add (more_label);

            show_all ();
        }

        private void add_help_iter (Gtk.Grid grid, int i, string iter_name, string description) {
            var name_label = new Gtk.Label (null);
            name_label.justify = Gtk.Justification.CENTER;
            name_label.set_markup ("<b>" + iter_name + "</b> ");

            var desc_label = new Gtk.Label (description);
            desc_label.max_width_chars = 60;
            desc_label.wrap = true;
            desc_label.halign = Gtk.Align.START;
            // FIXME: I can't align it to the left side yet
            // not working:
            // desc_label.justify = Gtk.Justification.LEFT;
            desc_label.justify = Gtk.Justification.FILL;

            grid.attach (name_label, 0, i);
            grid.attach (desc_label, 1, i);
        }
    }
}
