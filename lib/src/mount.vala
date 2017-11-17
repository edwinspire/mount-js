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


public async void m(){

//var location = GLib.File.new_for_uri ("ftp://anonymous@ftp.gnu.org");
	var location = GLib.File.new_for_uri ("smb://192.168.238.10/c$/");


   bool res = false;
        MountOperation? mount_op = null;
        var cancellable = new Cancellable ();
        const int MOUNT_TIMEOUT_SEC = 60;
uint mount_timeout_id = 100;
        try {
            bool mounting = true;
            bool asking_password = false;
            //assert (mount_timeout_id == 0);

  
             mount_timeout_id = Timeout.add_seconds (MOUNT_TIMEOUT_SEC, () => {

stdout.printf ("Montcando...\n");
                if (!mounting ) {
                    //mount_timeout_id = 0;
                    //debug ("Cancelled after timeout in mount mountable %s", file.uri);
                    //last_error_message = ("Timed out when trying to mount %s").printf (file.uri);
                    //state = State.TIMED_OUT;
                    //cancellable.cancel ();

                    return false;
                } else {
                    return true;
                }
            });


           
           /*
            //if (allow_user_interaction) {
                 mount_op = new MountOperation ();

                mount_op.ask_password.connect (() => {
                    debug ("Asking for password");
                    asking_password = true;
                });

                mount_op.reply.connect (() => {
                    debug ("Password dialog finished");
                    asking_password = false;
                });
            //}
            */
                mount_op = new MountOperation ();
                mount_op.anonymous = false;
                mount_op.username = "administrador";
                mount_op.password = "1234567";
                mount_op.domain = "prueba.com";


            stdout.printf ("Montando...\n");

            res =yield location.mount_enclosing_volume (GLib.MountMountFlags.NONE, mount_op, cancellable);


        } catch (Error e) {
      //      last_error_message = e.message;
        	//debug ("Mount_mountable failed: %s", e.message);
        	stdout.printf ("Mount_mountable failed0: %s\n", e.message);


  //last_error_message = e.message;
            if (e is IOError.ALREADY_MOUNTED) {
                stdout.printf  ("Already mounted\n");
         //       file.is_connected = true;
           //     res = true;
            } else if (e is IOError.NOT_FOUND) {
                stdout.printf ("Enclosing mount not found (may be remote share)");
                /* Do not fail loading at this point - may still load */
                try {
                    yield location.mount_mountable (GLib.MountMountFlags.NONE, mount_op, cancellable);
                    res = true;
                } catch (GLib.Error e2) {
                    //last_error_message = e2.message;
                    stdout.printf ("Unable to mount mountable");
                    res = false;
                }

            } else {
                //file.is_connected = false;
                //file.is_mounted = false;
                stdout.printf ("Setting mount null 1");
                //file.mount = null;
                stdout.printf ("Mount_mountable2 failed: %s", e.message);
                if (e is IOError.PERMISSION_DENIED || e is IOError.FAILED_HANDLED) {
                    //permission_denied = true;
                    stdout.printf ("Mount_mountable failed: 3");
                }

            }



        } finally {
            cancel_timeout (ref mount_timeout_id);

        }

        //debug ("success %s; enclosing mount %s", res.to_string (), file.mount != null ? file.mount.get_name () : "null");

}

 private bool cancel_timeout (ref uint id) {
        if (id > 0) {
            Source.remove (id);
            id = 0;
            return true;
        } else {
            return false;
        }
    }

public static int main (string[] args) {
    MainLoop loop = new MainLoop ();

  
  m();
///////////////////////////////////////////////////////////////////////



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