module src.tcontainer.UnorderedList;

private {
    import tango.core.Exception;
    import tango.core.Thread;
    import tango.core.sync.Mutex;

    debug(ThreadManager) {
        import tango.util.log.Trace;
        import tango.io.Console;
    }
}

protected class Bucket(T) {
private:
    class Node {
    private:
        T _data;
        Node _next;
        
    public:
        this(T data) {
            if(data !is null)
                _data = data;
        }

        T data() {
            return _data;
        }

        Node next() {
            return _next;
        }

        void next(Node value) {
            _next = value;
        }
    }

    Node        _head,
                _current;
    uint        _count = 0;

public:
    bool empty() {
        return _count == 0;
    }

    void push(T pushed) {
        _count++;

        if(_head is null) {
            _head = new Node(pushed);
            _current = _head;
        } else {
            _current.next = new Node(pushed);
            _current = _current.next;
        }
    }

    T pop() {
        _count = _count != 0 ? _count - 1 : _count;

        T ret = null;

        if(_head !is null) {
            ret = _head.data;
            if(_head.next !is null)
                _head = _head.next;
            else
                _head = null;
        }

        return ret;
    }

    uint size() {
        return _count;
    }
}

public class UnorderedList(T) {
private:
    Bucket!(T)[int] _buckets;
    Mutex[int]      _bucketsMutex;
    uint[int]       _count;
    int             _listCount;

public:
    this(int listCount) {
        _listCount = listCount;
        
        for(int i = 0; i < _listCount; i++) {
            _buckets[i]         = new Bucket!(T);
            _bucketsMutex[i]    = new Mutex(_buckets[i]);
            _count[i]           = 0;
        }
    }

    void push(T data) {
        bool did            = false;
        bool lockManaged    = false;
        int  used;
    
        if(data !is null) {
            for(int i = 0; i < _listCount; i++) {
                lockManaged = _bucketsMutex[i].tryLock;

                if(lockManaged == true) {
                    _buckets[i].push(data);
                    _count[i]++;
                    _bucketsMutex[i].unlock;
                    did = true;
                    break;
                }
            }

            if(!did) {
                used = _count[0];

                for(int i = 0; i < _listCount; i++) {
                    if(used > _count[i]) used = i;
                }

                _bucketsMutex[used].lock;
                    _buckets[used].push(data);
                    _count[used]++;
                _bucketsMutex[used].unlock;
            }
        }
    }

    T pop() {
        T temp              = null;
        bool   did          = false,
               lockManaged  = false;
        int    used;

        for(int i = 0; i < _listCount; i++) {
            lockManaged = _bucketsMutex[i].tryLock;

            if(lockManaged == true) {
                temp = _buckets[i].pop();

                if(temp is null) {
                    _bucketsMutex[i].unlock;
                    continue;
                } else {
                    _count[i]--;
                    _bucketsMutex[i].unlock;
                    did = true;
                    break;
                }
            }
        }

        if(!did) {
            used = 0;
            for(int i = 0; i < _listCount; i++) {
                if(_count[i] > used) used = i;
            }

            _bucketsMutex[used].lock;
                temp = _buckets[used].pop;
                _count[used]--;
            _bucketsMutex[used].unlock;
        }

        return temp;
    }

    bool empty() {
        bool temp = true;

        for(int i = 0; i < _listCount; i++) {
            if(temp is true && _count[i] == 0)
                return true;
            else temp = false;
        }

        return temp;
    }

    uint size() {
        uint temp;

        for(int i = 0; i < _listCount; i++) {
            temp += _count[i];
        }

        return temp;
    }
}
