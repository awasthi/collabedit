/**
 * 
 */
module server.server;

private {
	import tango.core.Thread;
	import tango.io.device.ThreadConduit;
}

alias void delegate(int, int) UnSubscribe;

// all Subscribers must implement this class
abstract class Subscriber: Thread {
	ThreadConduit notifiable, information, notify;
	UnSubscribe unSubscribe;
	uint port;
	
	this() {
		auto conduits = [new ThreadConduit, new ThreadConduit];
		this(conduits[0], conduits[1]);
	}

	this(ThreadConduit information_) {
		notifiable = new ThreadConduit;
		information = information_;
	}
	
	void unRegister(UnSubscribe unSubscribe) {
		this.unSubscribe = unSubscribe;
	}
	
	void notify(ThreadConduit notify) {
		this.notify = notify;
	}
}

class Reciever: Thread {
	Subscriber[int][int] subscribers;
	uint[] ports;
	
public:
	this(Subscriber[int][int] subscribers) {
		this.subscribers = subscribers;
		foreach(subscriber; subscribers)
			ports ~= subscriber.port;
	}

}

class Sender: Thread {
	Subscriber[int][int] subscribers;
	
}

class Server: Thread {
	Reciever reciever;
	Sender sender;
	
	Subscriber[int][int] subscribers;
	ThreadConduit[] conduits;
	ThreadConduit notify;

public:
	this() {
		this(null);
	}
	
	this(Subscriber[int][int] subscribers_) {
		reciever = new Reciever(subscribers);
		sender = new Sender(subscribers);
		
		if(subscribers_ !is null)
			subscribers = subscribers_;
		
		foreach(subscriber; subscribers) {
			subscriber.unRegister(unRegister);
			subscriber.notify(notify);
		}
		
		super(&run);			
	}
	
	void register(int upper, int lower, Subscriber subscribers) {
		subscribers[upper][lower] = subscriber;
	}
	
private:
	void unRegister(int upper, int lower) {
		subscribers[upper][lower] = null;
	}
	
	void run() {
		for(;;) {
			foreach(subscriber; subscribers) {
				if(subscriber !is null) {
					notify.clear;
					subscriber.notifiable.write("alive");
					this.sleep(5);
					char[] toRead;
					notify.read(toRead);
					if(toRead != "alive") {
						reciever.sleep(1);
						conduits ~= subscriber.information;
						conduits[0].clear;
						subscriber = null;
						delete subscriber;
						subscriber = new typeof(subscriber)(conduits[0]);
						conduits = new ThreadConduit[];
					}
				}
			}		
		}
	}
}