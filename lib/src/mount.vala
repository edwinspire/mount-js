public static void print_mount (Mount mount, string title) {
    stdout.printf ("%s:\n", title);

    stdout.printf ("  name: %s\n", mount.get_name ());
    stdout.printf ("  uuid: %s\n", mount.get_uuid ());
    stdout.printf ("  can-eject: %s\n", mount.can_eject ().to_string ());
    stdout.printf ("  can-unmount: %s\n", mount.can_unmount ().to_string ());
    stdout.printf ("  is-shadowed: %s\n", mount.is_shadowed ().to_string ());
    stdout.printf ("  default-location: %s\n", mount.get_default_location ().get_path ());
    stdout.printf ("  icon: %s\n", mount.get_icon ().to_string ());
    stdout.printf ("  root: %s\n", mount.get_root ().get_path ());

    try {
        string[] types = mount.guess_content_type_sync (false);
        stdout.printf ("  guess-content-type:\n");
        foreach (unowned string type in types) {
            stdout.printf ("    %s\n", type);
        }
    } catch (Error e) {
        stdout.printf ("Error: %s\n", e.message);
    }
}

public static int main (string[] args) {
    MainLoop loop = new MainLoop ();

  DBusConnection conn;
  DBusProxy device_proxy;


   try {
                 conn = Bus.get_sync (BusType.SESSION);
            } catch (Error e) {
                 error (e.message);
            }





            try {
                 device_proxy = new DBusProxy.sync (
                         conn,
                         DBusProxyFlags.NONE,
                         null,
                         "org.kde.kdeconnect",
                         "path",
                         "org.kde.kdeconnect.device",
                         null
                         );


             var c = conn.call_sync (
                             null,
                             "",
                             "ftp",
                             "mountAndWait",
                             null,
                             null,
                             DBusCallFlags.NONE,
                             -1,
                             null
                             );


stdout.printf ("    %s\n", device_proxy.get_object_path ());
                 
            } catch (Error e) {
                message (e.message);
            }





    VolumeMonitor monitor = VolumeMonitor.get ();

    //  Print a list of the mounts on the system:
    List<Mount> mounts = monitor.get_mounts ();
    foreach (Mount mount in mounts) {
        print_mount (mount, "Available");
    }


    // Emitted when a mount is added:
    monitor.mount_added.connect ((mount) => {
        print_mount (mount, "Mount added");
    });

    // Emitted when a mount changes:
    monitor.mount_changed.connect ((mount) => {
        // See GLib.Mount.changed
        print_mount (mount, "Mount changed");
    });

    // Emitted when a mount is about to be removed:
    monitor.mount_pre_unmount.connect ((mount) => {
        // See GLib.Mount.pre_unmount
        print_mount (mount, "Mount pre-unmount");
    });

    // Emitted when a mount is removed:
    monitor.mount_removed.connect ((mount) => {
        // See GLib.Mount.unmounted
        print_mount (mount, "Mount removed");
    });

/*
var m = new MountOperation();
m.anonymous = true;

var v = new Drive();
v.mount(MountMountFlags.NONE, m);
*/

    loop.run ();
    return 0;
}