/**
 * 
 */
module server.server;

private {
	import tango.core.Thread;
	import tango.io.device.ThreadConduit;
	import tango.net.ServerSocket;
}

alias void delegate(int, int) UnSubscribe;
alias void[] delegate(void[], bool) Encoder; //the boolean tells whether to encode or decode

// all Subscribers must implement this class
abstract class Subscriber: Thread {
	public ThreadConduit notifiable, information, notify, push; 
	// notifiable; what the server writes to for is alive requests
	// information; what Reciever writes to for giving information
	// notify; what this writes to to let server know is alive
	// push; what this writes to to put data on the internet
	UnSubscribe unSubscribe;
	
public:
	uint port;
	int upper, lower;
	
	this() {
		auto conduits = [new ThreadConduit, new ThreadConduit];
		this(conduits[0], conduits[1]);
	}

	this(ThreadConduit information_) {
		notifiable = new ThreadConduit;
		information = information_;
		
		super(&notifyLoop);
	}
	
	void unRegister(UnSubscribe unSubscribe) {
		this.unSubscribe = unSubscribe;
	}

	//all subclasses must implmement their threaded logic here
	abstract void run();
	
	void notifyLoop() {
		char[] to_read;
		for(; ;) {
			notifiable.read(to_read);
			if(read = "alive") {
				notify.write("alive");
			}
			notifiable.clear();
			
			run();
		}
	}
	
	
}

private class Handler : Thread { // this will connect and listen on certain ports
						 // must modify it to actually do this
	public ThreadConduit notifiable, notify;
	public Subscriber[int][int] subscribers;
	public uint port;
	
	public this(uint port) {
		this.port = port;
		notifiable = new ThreadConduit;
	}
	
	public void add(Subscriber subscriber) {
		subscribers[subscriber.upper][subscriber.lower] = subscriber;
	}	
}

private class Reciever: Thread {
	Subscriber[int][int] subscribers;
	Handler[uint] handlers;
	Encoder encode;
	ThreadConduit notify;
	
public:
	this(Subscriber[int][int] subscribers, Encoder encode) {
		this.subscribers = subscribers;
		this.encode = encode;
		
		for(int i = 0; i < subscribers.length; i++) {
			for(int j = 0; j < subscribers[i].length; i++) {
				subscribers[i][j].upper = i;
				subscribers[i][j].lower = j;
			}
		}
		
		foreach(subscriber; subscribers) {
			if(handlers[subscriber.port] !is null)
				handlers[subscriber.port].add(subscriber);
			else {
				handlers[subscriber.port] = new Handler(subscriber.port);
				handlers[subscriber.port].add(subscriber);
			}
		}
		
		foreach(handle; handlers)
			handle.notify(notify);
						
		super(&run);
	}
	
private:
	void run() {
		foreach(handler; handlers)
			handler.start;
		
		this.sleep(5);
		char[] to_read;
		Subscriber[int][int] temp;
		uint portTemp;
		for(;;) { //monitor the handlers here and restart them if necessary
			foreach(handle; handlers) {
				notify.clear;
				handle.notifiable.write("alive");
				this.sleep(10);
				notify.read(to_read);
				if(to_read != "alive") {
					temp = handle.subscribers;
					portTemp = handle.port;
					
					delete handle;
					handle = null;
					
					handle = new Handler(portTemp);
					handle.subscribers = temp;
					
					handle.start;
					this.sleep(5);
				}
			}
		}
	}

}

private class Sender: Thread { // must modify this to actually send stuff
							   // must notify all stuff of where to put data to
	Subscriber[int][int] subscribers;
	
}

class Server: Thread {
	Reciever reciever;
	Sender sender;
	
	Subscriber[int][int] subscribers;
	ThreadConduit[] conduits;
	ThreadConduit notify;
	Encoder encode;

public:
	this(Encoder encode) {
		this(null, encode);
	}
	
	this(Subscriber[int][int] subscribers_, Encoder encode) {
		this.encode = encode;
		reciever = new Reciever(subscribers, encode);
		sender = new Sender(subscribers, encode);
		
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
		sender.start;
		reciever.start;
		this.sleep(5);
		
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