namespace Services {
    public class Widgets.MainView : Gtk.Grid {
        private Gtk.ListStore list_store;

        public MainView () {
            orientation = Gtk.Orientation.VERTICAL;
            margin = 12;

            list_store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (string), typeof (string));

            var view = new Widgets.ServicesView ();
            view.set_model (list_store);

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.add (view);
            scrolled.expand = true;

            var frame = new Gtk.Frame (null);
            frame.add (scrolled);

            add (frame);

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
    }
}
