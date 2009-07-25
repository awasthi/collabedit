module src.threading.ThreadManager;

private {
    import tango.core.Exception;
    import tango.core.Thread;
    import tango.core.sync.Mutex;
    import src.tcontainers.UnorderedList;

    debug(ThreadManager) {
        import tango.util.log.Trace;
        import tango.io.Console;
    }
}

alias void delegate()   TaskDG;
alias TaskManager       ThreadManager;
alias KillableThread    PermanentTask;

public class KillableThread: Thread {
protected:
    int                     _kill;
    Mutex                   _killMutex;
    void delegate(int kill) _call;

    void run() {
        int _temp;

        _killMutex.lock;
            _temp = _kill;
        _killMutex.unlock;

        while(_temp != 1) {
            _call(_temp);

        _killMutex.lock;
            _temp = _kill;
        _killMutex.unlock;
        }
    }

public:
    this(void delegate(int kill) call) {
        _kill = -1;
        _call = call;
        _killMutex = new Mutex;
        super(&run);
    }

    void exit() {
        _killMutex.lock;
            _kill = 1;
        _killMutex.unlock;
    }
}

private class TaskRunner: KillableThread {
private:
    bool execute(bool both = true) {
        TaskDG temp;

        if(_store.empty && both) {
            if(_next !is null) {
                temp = _next.steal;

                if(temp !is null)
                    temp();
            }
        } else {
            temp = _store.pop;
            if(temp !is null)
                temp();
        }
        if(temp is null)
            return false;
        return true;
    }

    void slot(int kill) {
        if(kill != 0)
            execute();
        if(kill == 2) {
            if(!execute(false))
                super.exit();
        }   
    }

public:
    UnorderedList!(TaskDG)      _store;
    int                         _threadCount;
    TaskRunner                  _next;
    TaskManager                 _manager;

    this(TaskManager tman, int threadCount, int IAm) {
        _manager = tman;
        _threadCount = threadCount;
        _store = new UnorderedList!(TaskDG)
                    (IAm == 0 ? ((2 * _threadCount) + 2) : (((IAm + _threadCount) * 2) + 2));
        super(&slot);
    }

    void pause() {
        _killMutex.lock;
            _kill = 0;
        _killMutex.unlock;
    }

    void proceed() {
        _killMutex.lock;
            _kill = -1;
        _killMutex.unlock;
    }

    void finish() {
        _killMutex.lock;
            _kill = 2;
        _killMutex.unlock;
    }

    TaskDG steal() {
        if(_store.empty) {
            if(_next !is null)
                return _next.steal;
        } else
            return _store.pop;
        return null;
    }
}

public class TaskManager {
private:
    TaskRunner[int]         _tasks;
    int                     _threadCount;

public:
    this(int threadCount) {
        _threadCount = threadCount;
        TaskRunner previous;
    
        for(int i = 0; i < _threadCount; i++) {
            _tasks[i] = new TaskRunner(this, _threadCount, i);
            _tasks[i].pause;
            
            if(i != 0) {
                previous._next = _tasks[i];
            }

            previous = _tasks[i];
        }
    }

    ~this() {
        finish();
        join();
    }

    void start() {
        for(int i = 0; i < _threadCount; i++) {
            _tasks[i].proceed;
            _tasks[i].start;
        }
    }

    void kill() {
        for(int i = 0; i < _threadCount; i++) {
            _tasks[i].exit;
        }
    }

    void finish() {
        for(int i = 0; i < _threadCount; i++) {
            _tasks[i].finish;
        }
    }

    void join() {
        for(int i = 0; i < _threadCount; i++) {
            if (_tasks[i] !is null) _tasks[i].join;
        }
    }

    void add(TaskDG task) {
        int temp = 0;

        for(int i = 0; i < _threadCount; i++) {
            if(_tasks[i]._store.size < _tasks[temp]._store.size)
                temp = i;
        }

        _tasks[temp]._store.push(task);
    }
}

debug(ThreadManager) {
    class Temp {
        int i;

    public:
        this(int _i) { i = _i;}
        void dont() {
            Trace.formatln("I'm a thread {}", i);
        }
    }

    void main() {
        auto man = new ThreadManager(3);

        man.start();

        for(int i = 0; i < 500000; i++) {
            man.add(&(new Temp(i)).dont);
        }

        delete man;
    }
} 