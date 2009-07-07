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
}

debug(ThreadManager) {
            class temp {
                int i3;
                public:
                void dont() {
                    Trace.formatln("I'm a thread {}", i3);
                }
                this(int i2 = 0) {
                    i3 = i2;
                }
            }
    void main() {
        scope man = new ThreadManager(4, 4);
        man.start;
        for(int i = 0; i < 10000000; i++) {
            man.add(&(new temp(i)).dont);
        }

        Thread.sleep(1000);

    }
}