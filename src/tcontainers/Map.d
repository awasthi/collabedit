module src.tcontainers.Map; 

private {
    import tango.core.Exception;
    import tango.core.Thread;
    import tango.core.sync.Mutex;

    debug(Map) {
        import tango.util.log.Trace;
        import tango.io.Console;
    }
}

public class Map(K, V) {
private:
    V[K]        _map;
    Mutex[K]    _mapMutex;
    uint        _size;

public: 
    void push(K key, V value) {
        _mapMutex[key] = new Mutex;

        _mapMutex[key].lock;
            _map[key] = value;
        _mapMutex[key].unlock;

        _size++;
    }

    V pull(K key) {
        V ret;

        _mapMutex[key].lock;
            ret = _map[key];
        _mapMutex[key].unlock;

        return ret;
    }

    V pop(K key) {
        V ret = pull(key);

        delete _mapMutex[key]
        _map[key] = null;

        _size--;

        return ret;
    }

    bool empty() {
        return _size == 0;
    }

    uint size() {
        return _size;
    }
}