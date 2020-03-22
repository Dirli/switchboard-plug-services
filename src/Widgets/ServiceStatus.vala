namespace Services {
    public class Widgets.ServiceStatus : Gtk.Dialog {
        public ServiceStatus (Gtk.Window parent, string s_name, string status) {
            Object (
                border_width: 6,
                deletable: false,
                destroy_with_parent: true,
                resizable: false,
                title: s_name,
                transient_for: parent,
                width_request: 420,
                window_position: Gtk.WindowPosition.CENTER_ON_PARENT
            );

            var status_label = new Gtk.Label (status);
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

            show_all ();
        }
    }
}
