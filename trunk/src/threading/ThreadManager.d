module src.threading.ThreadManager;

private {
    import tango.util.container.CircularList;
    import tango.core.Exception;
    import tango.core.Thread;
    import tango.core.sync.Mutex;

    debug(ThreadManager) {
        import tango.util.log.Trace;
    }
}

alias void delegate() TaskDG;

/+ old
private class TaskList {
private:
    class Node {
    public:
        TaskDG dg;
        Node prev, next;

        this(TaskDG task) {
            dg = task;
        }
    }
    Node head, current;
    uint count;


public:
    void append(TaskDG task) {
        count++;

        if(head is null) {
            head = new Node(task);
            current = head;
        } else {
            current.next = new Node(task);
            current.next.prev = current;
            current = current.next;
        }
    }

    TaskDG removeHead() {
        count--;

        TaskDG temp = null;

        if(! (head is null)) {
            temp = head.dg;

            if(! (head.next is null)) {
                head = head.next;
            }
            else head = current = null;
        }

        return temp;
    }

    uint size() {
        return count;
    }

    bool isEmpty() {
        return count == 0;
    }
}

private class Store {
private:
    TaskList   store;
    Mutex                   storeAccess;

public:
    this() {
        store = new TaskList;
        storeAccess = new Mutex(store);
    }

    ~this() {
        delete storeAccess;
        delete store;
    }

    void push(TaskDG task) {
        if(task !is null) {
            storeAccess.lock;
                store.append(task);
            storeAccess.unlock;
        }
    }

    TaskDG pop() {
        TaskDG task = null;

        storeAccess.lock;
            if(!store.isEmpty)
                task = store.removeHead;
        storeAccess.unlock;

        return task;
    }

    uint count() {
        uint count;

        storeAccess.lock;
            count = store.size;
        storeAccess.unlock;

        return count;
    }

    bool empty() {
        bool temp;

        storeAccess.lock;
            temp = store.isEmpty;
        storeAccess.unlock;

        return temp;
    }
}

private class Task: Thread {
private:
    int             kill;
    Mutex           killAccess;
    ThreadManager   man;
    int num;

    void run() {
        killAccess.lock;
            int killTemp = kill;
        killAccess.unlock;

        TaskDG temp;

        while(killTemp != 1) {
            if(killTemp == 0)
                Thread.yield;
            if(killTemp == -1) {
                if(store.empty) {
                    try {
                        if(man !is null) {
                        synchronized(man) {
                            if(man !is null)
                                man.steal(num);
                        } }
                    } catch {}
                }

                temp = store.pop;
                if(temp !is null)
                    temp();
            }


            killAccess.lock;
                killTemp = kill;
            killAccess.unlock;
        }
    }

public:
    Store           store;

    this(ThreadManager _man, int _num) {
        man = _man;
        kill = -1;
        killAccess = new Mutex;
        store = new Store;
        num = _num;

        super(&run);
    }

    void Kill() {
        killAccess.lock;
            kill = 1;
        killAccess.unlock;
    }

    void pause() {
        killAccess.lock;
            kill = 0;
        killAccess.unlock;
    }

    void proceed() {
        killAccess.lock;
            kill = -1;
        killAccess.unlock;
    }
}

public class ThreadManager {
private:
    Task[int]           threads;
    int                 threadNum,
                        grainSize;
    bool                started = false;
    Mutex               stealAccess;
    Mutex               storeAccess;
    int                 pushTo;

public:
    this(int _threadNum = 4, int _grainSize = 4) {
        threadNum = _threadNum;
        grainSize = _grainSize;
        stealAccess = new Mutex;

        //toBe = new Store;
        //storeAccess = new Mutex(toBe);

        for(int i = 0; i < threadNum; i++) {
            threads[i] = new Task(this, i);
            threads[i].pause;
        }
    }

    ~this() {
        for(int i = 0; i < threadNum; i++) {
            threads[i].Kill();
        }
        for(int i = 0; i < threadNum; i++) {
            threads[i].join();
        }
    }

    void start() {
        for(int i = 0; i < threadNum; i++) {
            threads[i].start;
        }
    }

    void add(TaskDG fun) {
        if(!started) {
            for(int i = 0; i < threadNum; i++) {
                threads[i].proceed;
            }
            started = true;
        }

        bool pushed = false;

        for(int i = 0; i < threadNum && !pushed; i++) {
            if(threads[i].store.empty) {
                threads[i].store.push(fun);
                pushed = true;
            }
        }

        if(!pushed) {
            threads[pushTo].store.push(fun);
        }
    }

    synchronized void steal(int task) {
            pushTo = task;
    }
} +/

private class TaskList {
private:
    Node        head,
                current;
    uint        count = 0;

    class Node {
    public:
        TaskDG  dg;
        Node    next;

        this(TaskDG task) {
            dg = task;
        }
    }

public:
    bool empty() {
        return count == 0;
    }

    void push(TaskDG task) {
        count++;

        if(head is null) {
            head = new Node(task);
            current = head;
        } else {
            current.next = new Node(task);
            current = current.next;
        }
    }

    TaskDG pop() {
        count = count != 0 ? count - 1 : count;

        TaskDG temp = null;

        if(head !is null) {
            temp = head.dg;
            if(head.next !is null)
                head = head.next;
            else
                head = null;
        }

        return temp;
    }

    uint size() {
        return count;
    }
}

private class TaskStore {
private:
    TaskList[int]       lists;
    Mutex[int]          listsMutex;
    uint[int]           count;
    int                 numList;

public:
    this(int listNum) {
        numList = listNum;

        for(int i = 0; i < numList; i++) {
            lists[i] = new TaskList;
            listsMutex[i] = new Mutex(lists[i]);
            count[i] = 0;
        }
    }

    void push(TaskDG task) {
        bool did            = false;
        bool lockManaged    = false;
        int  used;
    
        if(task !is null) {
            for(int i = 0; i < numList; i++) {
                lockManaged = listsMutex[i].tryLock;

                if(lockManaged == true) {
                    lists[i].push(task);
                    count[i]++;
                    listsMutex[i].unlock;
                    did = true;
                    break;
                }
            }

            if(!did) {
                used = count[0];

                for(int i = 0; i < numList; i++) {
                    if(used > count[i]) used = i;
                }

                listsMutex[used].lock;
                    lists[used].push(task);
                    count[used]++;
                listsMutex[used].unlock;
            }
        }
    }

    TaskDG pop() {
        TaskDG temp         = null;
        bool   did          = false,
               lockManaged  = false;
        int    used;

        for(int i = 0; i < numList; i++) {
            lockManaged = listsMutex[i].tryLock;

            if(lockManaged == true) {
                temp = lists[i].pop();

                if(temp is null) {
                    listsMutex[i].unlock;
                    continue;
                } else {
                    count[i]--;
                    listsMutex[i].unlock;
                    did = true;
                    break;
                }
            }
        }

        if(!did) {
            used = 0;
            for(int i = 0; i < numList; i++) {
                if(count[i] > used) used = i;
            }

            listsMutex[used].lock;
                temp = lists[used].pop;
                count[used]--;
            listsMutex[used].unlock;
        }

        return temp;
    }

    bool empty() {
        bool temp = true;

        for(int i = 0; i < numList; i++) {
            if(temp is true && count[i] == 0)
                temp = true;
            else temp = false;
        }

        return temp;
    }

    uint size() {
        uint temp;

        for(int i = 0; i < numList; i++) {
            temp += count[i];
        }

        return temp;
    }
}

private class Task: Thread {
private:
    Task            next;
    int             threadNum;
    ThreadManager   man;
    int             _kill;
    Mutex           killAccess;

    void run() {
        TaskDG temp;
        int temp1;

        void doIt() {
            if(store.empty) {
                if(next !is null) {
                    temp = next.steal;

                    if(temp !is null)
                        temp();
                }
            } else {
                temp = store.pop;
                if(temp !is null)
                    temp();
            }
        }

        killAccess.lock;
            temp1 = _kill;
        killAccess.unlock;

        while(temp1 != 1) {

            if(temp1 != 0)
                doIt();

            if(temp1 == 2) {
                while(!store.empty) {
                    temp = store.pop;
                    if(temp !is null)
                        temp();
                    else
                        break;
                }
                break;
            }

            killAccess.lock;
                temp1 = _kill;
            killAccess.unlock;
        }
    }

public:
    TaskStore       store;

    this(ThreadManager _man, int _threadNum) {
        man = _man;
        threadNum = _threadNum;
        store = new TaskStore(threadNum + 1);
        killAccess = new Mutex;
        _kill = -1;

        super(&run);
    }

    void Kill() {
        killAccess.lock;
            _kill = 1;
        killAccess.unlock;
    }

    void pause() {
        killAccess.lock;
            _kill = 0;
        killAccess.unlock;
    }

    void proceed() {
        killAccess.lock;
            _kill = -1;
        killAccess.unlock;
    }

    void finish() {
        killAccess.lock;
            _kill = 2;
        killAccess.unlock;
    }

    TaskDG steal() {
        if(store.empty) {
            if(next !is null)
                return next.steal;
        } else {
            return store.pop;
        }
        return null;
    }
}

public class ThreadManager {
private:
    Task[int]       tasks;
    int             threadNum;

public:

    this(int numThread) {
        threadNum = numThread;
        Task prev;
        for(int i = 0; i < threadNum; i++) {
            tasks[i] = new Task(this, threadNum);
            tasks[i].pause;
            if(i != 0) {
                prev.next = tasks[i];
                prev = tasks[i];
            } else
                prev = tasks[i];
        }
    }

    ~this() {
        this.finish();
        this.join();
    }

    void start() {
        for(int i = 0; i < threadNum; i++) {
            tasks[i].proceed;
            tasks[i].start;
        }
    }

    void kill() {
        for(int i = 0; i < threadNum; i++) {
            tasks[i].Kill;
        }
    }

    void finish() {
        for(int i = 0; i < threadNum; i++) {
            tasks[i].finish;
        }
    }

    void add(TaskDG task) {
        int used = 0;

        for(int i = 0; i < threadNum; i++) {
            if(tasks[i].store.size < tasks[used].store.size)
                used = i;
        }

        tasks[used].store.push(task);
    }

    void join() {
        for(int i = 0; i < threadNum; i++) {
            if(tasks[i] !is null)
                tasks[i].join;
        }
    }
}

debug(ThreadManager) {
    class Temp {
        int i;

    public:
        this(int _i) { i = _i; }
        void dont() {
            Trace.formatln("I'm a thread {}", i);
        }
    }

    void main() {
        auto man = new ThreadManager(4);

        man.start();

        for(int i = 0; i < 500000; i++) {
            man.add(& ( new Temp(i) ).dont);
        }

        delete man;
    }
} 