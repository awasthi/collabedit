module src.threading.TaskManager;

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
typedef KillableThread  PermanentTask;

public interface IExitThread {
    void exit();
    void Start();
}

public class KillableThread: Thread, IExitThread {
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

    void Start() {
        super.start;
    }
}

public interface ITaskableTask: IExitThread {
public:
    void    pause();
    void    proceed();
    void    finish();
    void    add(TaskDG task);
    uint    count();
}

private class TaskRunner: KillableThread, ITaskableTask {
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

    void add(TaskDG task) {
        _store.push(task);
    }

    uint count() {
        return _store.size;
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
    ITaskableTask[int]      _ttasks;
    PermanentTask[int]      _ptasks;
    int                     _threadCount;
    int                     _ttCount, _ptCount;

public:
    this(int threadCount) {
        _threadCount = threadCount;
        _ttCount = _ptCount = 0;
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
            _tasks[i].Start;
        }
        for(int i = 0; i < _ttCount; i++) {
            if(_ttasks[i] !is null) {
                _ttasks[i].proceed;
                _ttasks[i].Start;
            }
        }
    }

    void kill() {
        for(int i = 0; i < _threadCount; i++) {
            _tasks[i].exit;
        }
        for(int i = 0; i < _ttCount; i++) {
            if(_ttasks[i] !is null) {
                _ttasks[i].exit;
            }
        }
        for(int i = 0; i < _ptCount; i++) {
            if(_ptasks[i] !is null) 
                _ptasks[i].exit;
        }
    }

    void finish() {
        for(int i = 0; i < _threadCount; i++) {
            _tasks[i].finish;
        }
        for(int i = 0; i < _ttCount; i++) {
            if(_ttasks[i] !is null) {
                _ttasks[i].finish;
            }
        }
    }

    void join() {
        for(int i = 0; i < _threadCount; i++) {
            if (_tasks[i] !is null) _tasks[i].join;
        }
    }

    void add(TaskDG task) {
        int[2]     temp;
        temp[0] = temp[1] = 0;
        bool    which = true;

        for(int i = 0; i < _threadCount; i++) {
            if(_tasks[i].count < _tasks[temp[0]].count)
                temp[0] = i;
        }

        for(int i = 0; i < _ttCount; i++) {
            if(_ttasks[temp[1]] !is null && _ttasks[i] !is null)
                if(_ttasks[i].count < _ttasks[temp[1]].count)
                    temp[1] = i;
        }

        if(_ttasks !is null)
            if(_ttasks[temp[1]] !is null)
                if(_ttasks[temp[1]].count < _tasks[temp[0]].count)
                    which = false;

        if(!which && _ttasks[temp[1]] !is null)
            _ttasks[temp[1]].add(task);
        else
            _tasks[temp[0]].add(task);
    }

    void add(PermanentTask task) {
        _ptasks[_ptCount++] = task;
    }

    void add(ITaskableTask task) {
        _ttasks[_ttCount++] = task;
    }
}

debug(ThreadManager) {
    class Temp {
        int i;

    public:
        this(int _i) { i = _i;}
        void dont() {
            //Trace.formatln("I'm a thread {}", i);
        }
    }

    void main() {
        for(int j = 0; j < 500; j++) {

            Trace.formatln(`{}`, j);

            auto man = new ThreadManager(3);

            man.start();

            for(int i = 0; i < 500000; i++) {
                man.add(&(new Temp(i)).dont);
            }

            delete man;
        }
    }
} 
