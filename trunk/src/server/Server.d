module src.server.Server;

private {
    import src.tcontainer.Map;
    import src.threading.TaskManager;
    import tango.util.convert;
    import tango.util.log.Trace;
    import tango.io.vfs.model.Vfs;
    import tango.io.vfs.FileFolder;
    import tango.core.Exception;
    import tango.core.Thread;
    import tango.core.sync.Mutex;
} 

void main(char[][] args) {
    uint cores = 2;
    char[] servername = "sps v0.01 -core NUM";

    try {
        bool use = false;

        foreach(argc, arg; args) {
            argc == 0 ? cores = 2 : argc == 1 && argv == "-core" ? use = true : use = false;
            use ? cores = to!(uint)(argv) : cores = 2;
        }
    } catch {
        Trace.formatln("Usage: ");
        Trace.formatln(servername);
        Trace.formatln("Default core: 2");
    }

        auto host = new FileHost(`/var/sps/server.lck`);
        
    if(host.exist) {
        Trace.formatln("SPS server is already running.");
        Trace.formatln("If there has been an error");
        Trace.formatln("Please report it.");
        Trace.formatln("If the server is no longer running");
        Trace.formatln("and you can still not open");
        Trace.formatln("a running instance of this program");
        Trace.formatln("remove the file /var/sps/server.lck");
    } else {
        host.create;
    }

    (new Server(cores)).join;
}

class Server: Thread {
private:
    TaskManager _manager;
    Handle[20]  _handles;

public:
    this(uint numCore) {
        _manager = new TaskManager(numCore);

        super(&run);
        super.start;
    }

}

class Handle {

public:
    void handle() {

    }

    this() {

    }

    bool avail() {

    }

    void reinit() {

    }
}
