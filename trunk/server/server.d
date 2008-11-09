/**
 * Author: Lester L. Martin
 * Copyright: (Shared).apply("lmartin92", "collabEdit");
 */

//module name (more intuitive name may be needed)
module server.server;

//imports needed to make this work
private {
	import tango.core.Thread;
	import tango.io.device.ThreadConduit;
	import tango.net.SocketConduit;
	import tango.net.ServerSocket;
	import tango.io.stream.DataStream;
}

// renaming delegates to easier to use names
alias void delegate(int, int) UnSubscribe;
alias void[] delegate(void[], bool = false) Encoder; //the bool tells whether to encode or decode (true to decode)

// all Subscribers must implement this class
abstract class Subscriber: Thread {
	
	// this is how it knows how to unsubscribe
	UnSubscribe unSubscribe;

	public:
		// the port that this subscriber listens on
		uint port;
		
		// defines what part of the protocol it listens on
		int upper, lower;
		
		// notifiable; what the server writes to for is alive requests
		// information; what Reciever writes to for giving information
		// notify; what this writes to to let server know is alive
		// push; what this writes to to put data on the internet
		ThreadConduit notifiable, information, notify, push;
		
		// this calls the true constructor
		this() {
			auto conduits = new ThreadConduit;
			this(conduits);
		}
		
		// this creates all data needed to run such as its conduits
		// and notifies parent of what should be used for threading
		this(ThreadConduit information_) {
			notifiable = new ThreadConduit;
			information = information_;

			super(&notifyLoop);
		}
		
		// Server class uses this to tell it where it unsubscribe method is
		void unRegister(UnSubscribe unSubscribe) {
			this.unSubscribe = unSubscribe;
		}

		// all subclasses must implmement their threaded logic here
		abstract void run();
		
		// this handles all the "alive" messaging and replies accordingly
		void notifyLoop() {
			char[] to_read;
			for(; ; ) {
				if(notifiable.isAlive) {
					notifiable.read(to_read);
					
					if(to_read == "alive") {
						notify.write("alive");
					}
					
					notifiable.clear();
				}

				run();
			}
		}

		// all subclasses implement so that it deletes itself after restarting; 
		// must also handle pushing old variables that need
		// preservation back into new self
		abstract Subscriber restart();

}

private class Handler: Thread { 
	// this will connect and listen on certain ports
	// must modify it to actually do this
	// must modify to have infinite pull push loop (EG Run that is called on start)
	// this should work like get first 2 integers off, then decode (encode(..,false)) 
	// the rest and push to subscribers
package:
	ThreadConduit notifiable, notify;
	Subscriber[int][int] subscribers;
	uint port;
	
private:
	Sender sender;
	Encoder encode;
	DataInput inputWrapper;
	
public:
	this(uint port, Sender sender, Encoder encode) {
		this.port = port;
		notifiable = new ThreadConduit;
		this.sender = sender;
		this.encode = encode;
		
		super(&run);
	}

	void add(Subscriber subscriber) {
		subscribers[subscriber.upper][subscriber.lower] = subscriber;
	}

	// must handle preservation of variables and * but must create a new self and kill old self
	Handler restart() {
		Handler handle = new Handler(port, sender, encode);
		handle.subscribers = subscribers;
		handle.notifiable = notifiable;
		handle.notify = notify;
		
		this = null;
		delete this;
		
		return handle;
	}
	
private:
	void run() {
		ServerSocket sock = new ServerSocket(port, 1000, true);
		int high, low;
		void[] rest;
		char[] to_read;
		for (; ;) {
			if(notifiable.isAlive) {
				notifiable.read(to_read);
				notifiable.clear;
				
				if(to_read == "alive")
					notify.write("alive");
			}
			
			inputWrapper = new DataInput(sock.accept);
			
			high = inputWrapper.getInt;
			low = inputWrapper.getInt;
			rest = inputWrapper.get;
			rest = encode(rest, true);
			
			if(subscribers[high][low] !is null) 
				subscribers[high][low].information.write(rest);
		}
	}
}

private class Reciever: Thread {
	Subscriber[int][int] subscribers;
	Handler[uint] handlers;
	Encoder encode;
	ThreadConduit notify;
	Sender sender;

public:
	this(Subscriber[int][int] subscribers, Encoder encode, Sender sender) {
		this.subscribers = subscribers;
		this.encode = encode;
		this.sender = sender;

		for(int i = 0; i < subscribers.length; i++) {
			for(int j = 0; j < subscribers[i].length; i++) {
				subscribers[i][j].upper = i;
				subscribers[i][j].lower = j;
			}
		}

		foreach(subscribers2; subscribers) {
			foreach(subscriber; subscribers2) {
				if(handlers[subscriber.port] !is null)
					if(subscriber !is null)
						handlers[subscriber.port].add(subscriber);
					else {
						if(subscriber !is null) {
							handlers[subscriber.port] = new Handler(
									subscriber.port, sender, encode);
							handlers[subscriber.port].add(subscriber);
						}
					}
			}
		}

		foreach(handle; handlers)
			handle.notify = notify;

		super(&run);
	}

private:
	void run() {
		foreach(handler; handlers)
			handler.start;

		this.sleep(5);
		char[] to_read;
		for(; ; ) { //monitor the handlers here and restart them if necessary
			foreach(handle; handlers) {
				notify.clear;
				handle.notifiable.write("alive");
				this.sleep(10);
				notify.read(to_read);
				if(to_read != "alive") {

					handle = handle.restart();

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
	Encoder encode;

	public this(Subscriber[int][int] subscribers, Encoder encode) {
		this.subscribers = subscribers;
		this.encode = encode;
	}

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
		sender = new Sender(subscribers, encode);
		reciever = new Reciever(subscribers, encode, sender);

		if(subscribers_ !is null)
			subscribers = subscribers_;

		foreach(subscribers2; subscribers) {
			foreach(subscriber; subscribers2) {
				subscriber.unRegister(&unRegister);
				subscriber.notify = notify;
			}
		}

		super(&run);
	}

	void register(int upper, int lower, Subscriber subscriber) {
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

		for(; ; ) {
			foreach(subscribers2; subscribers) {
				foreach(subscriber; subscribers2) {
					if(subscriber !is null) {
						notify.clear;
						subscriber.notifiable.write("alive");
						this.sleep(5);
						char[] toRead;
						notify.read(toRead);
						if(toRead != "alive") {
							subscriber = subscriber.restart;
							
							subscriber.start;
						}
					}
				}
			}
		}
	}
}
