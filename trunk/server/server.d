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
	import tango.io.selector.SelectSelector;
	import tango.io.selector.EpollSelector;
	import tango.io.selector.PollSelector;
	import tango.io.selector.SelectorException;
	import tango.io.selector.model.ISelector;
	import tango.core.sync.Mutex;
}

// renaming delegates to easier to use names
alias void delegate(int, int) UnSubscribe;
alias void[] delegate(void[], bool = false) Encoder; //the bool tells whether to encode or decode (true to decode)

// all Subscribers must implement this class
// this has many methods that must be implemented to be compliant
// this is to make it's threaded nature act correctly and thread
// through your code and do everything you would do if you didn't
// have to write this as a subclass of this class
abstract class Subscriber: Thread {

	// this is how it knows how to unsubscribe
	UnSubscribe unSubscribe;

public:
	// the port that this subscriber listens on
	uint port;

	// defines what part of the protocol it listens on
	int upper, lower;

	bool obey;

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
	// to be fully compliant, implement this method in such a way
	// that it falls through itself very quickly, and also in a way
	// that if it needs to fail, don't write it that it does a step
	// and then needs to do a step but waits until next call to do those
	// if that type of stuff is needed, you must overide notifyLoop
	// and use it or, if you need to use Threads and fibers, you must
	// modify deallocate that all those threads and 
	// fibers that you have need of, in fact, you should implement
	// deallocate for all things that keep around resources so that
	// when the thread exits, you will not leave threads and other
	// resources lying around
	abstract void run();

	// use this to kill all resources that are not needed when this
	// thread dies
	abstract void dealocate();
	
	// this handles all the "alive" messaging and replies accordingly
	void notifyLoop() {
		char[] to_read;
		for(; ; ) {
			if(notifiable.isAlive) {
				notifiable.read(to_read);

				if(to_read == "alive") {
					notify.write("alive");
				}

				if(to_read == "die" && obey) {
					notifiable.clear;
					deallocate();
					return;
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
	bool obey = false;

private:
	Sender sender;
	Encoder encode;
	DataInput inputWrapper;
	ISelector selector;
	ServerSocket server;

public:
	this(uint port, Sender sender, ISelector selector, Encoder encode) {
		this.port = port;
		notifiable = new ThreadConduit;
		this.sender = sender;
		this.encode = encode;
		this.selector = selector;
		server = new ServerSocket(port, 1000, true);

		super(&run);
	}

	void add(Subscriber subscriber) {
		subscribers[subscriber.upper][subscriber.lower] = subscriber;
	}

	void unRegister(int high, int low) {
		subscribers[high][low] = null;
	}

	// must handle preservation of variables and * but must create a new self and kill old self
	Handler restart() {
		Handler handle = new Handler(port, sender, encode);
		handle.subscribers = subscribers;
		handle.notifiable = notifiable;
		handle.notify = notify;
		handle.obey = false;
		this.obey = true;
		this.notifiable.write("die");

		this = null;
		delete this;

		return handle;
	}

private:
	// must accept connections
	// must loop through connections checking for ready to write or read (Selector)
	// must notify Sender of Clients (share selector)
	void run() {
		selector.register(server, Event.Read);
		SocketConduit temp;
		int count;

		for(; ; ) {

			// do I tell that I'm alive?
			if(notifiable.isAlive) {
				notifiable.read(to_read);

				if(to_read == "alive") {
					notify.write("alive");
				}

				if(to_read == "die" && obey) {
					notifiable.clear();
					return;
				}

				notifiable.clear();
			}

			count = selector.select(1);

			if(count > 0) {
				foreach(SelectionKey key; selector.selectedSet) {
					temp = cast(SocketConduit) key.conduit;
					// must get information from temp to be sent to the subscriber
					// then must get information from connection to be sent to subscriber

					if(key.isReadable) {
						if(key.conduit is server)
							selector.register(server.accept, Event.Read);
						else {
							selector.register(key.conduit,
									Event.Read | Event.Write,
									key.attachment);
							scope input = new DataInput(key.conduit);
							int high, low;
							high = input.getInt;
							low = input.getInt;
							if(subscriber[high][low] !is null) {
								void[] message = input.array;
								message = encode(message, true);
								auto
										socket = (cast(SocketConduit) key.conduit).socket;
								scope output = new DataOutput(
										subscriber[high][low].information);
								output.putInt(port);
								output.putInt(socket.remoteAddress.addr);
								output.array(message);
								output.flush;
							}
						}
					}
					if(key.isError() || key.isHangup() || key.isInvalidHandle()) {
						selector.unregister(key.conduit);
						key.conduit.close;
					}
				}
			}
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
									subscriber.port, sender, selector,
									encode);
							handlers[subscriber.port].add(subscriber);
						}
					}
			}
		}

		foreach(handle; handlers)
			handle.notify = notify;

		super(&run);
	}

	void register(int upper, int lower, Subscriber subscriber) {
		foreach(handle; handlers)
			handle.add(subscriber);
		subscribers[upper, lower] = subscriber;
	}

	void unRegister(int upper, int lower) {
		foreach(handle; handlers)
			handle.unRegister(upper, lower);
		subscribers[upper, lower] = null;
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

//must finish, must add registration and unregistration functions
private class Sender: Thread { // must modify this to actually send stuff
	// must notify all stuff of where to put data to
	Subscriber[int][int] subscribers;
	Encoder encode;
	ISelector selector;
	ThreadConduit notifiable;

public:
	this(Subscriber[int][int] subscribers, Encoder encode,
			ISelector selector) {
		this.subscribers = subscribers;
		this.encode = encode;
		this.selector = selector;

		foreach(subscriber; subscribers) {
			subscriber.push = notifiable;
		}

		super(&run);
	}

	void register(int upper, int lower, Subscriber subscriber) {
		subscribers[upper][lower] = subscriber;
	}

	void unRegister(int upper, int lower) {
		subscriber[upper][lower] = null;
	}

private:

	// pulls data off the notifiable conduit the standard way 
	// the data on the conduit must have been pushed like
	// int, int, int, int, void[];
	// where first int is port, next int address, next high, next low
	// and void[] is subscribable data
	class Pushable {
	public:
		void[] push;
		int port;
		int address;
		int high;
		int low;

		// should pull off the port and address
		// and should store true message
		// and should pull high and low off as well;
		this(void[] push) {
			scope buf = new Buffer(push);
			scope input = new DataInput(buf);
			port = input.getInt;
			address = input.getInt;
			high = input.getInt;
			low = input.getInt;
			this.push = input.array;
		}
	}

	class Match {

		SelectionKey key;
		Pushable push;

	public:
		// used by match function to initialize
		this(SelectionKey key, Pushable push) {
			this.key = key;
			this.push = push;
		}

		// call this to push information to internet
		void push() {
			scope output = new DataOutput(key.conduit);
			output.putInt(push.high);
			output.putInt(push.low);
			output.array(push.push);
			output.flush;
		}
}

	Pushable[] toPush;

	// pull data from thread conduit that is a full seperated
	// message
	void[] pull() {
		void[] to_return;
		scope input = new DataInput(notifaible);
		scope output = new DataOutput(new Buffer(to_return));
		output.putInt(input.getInt);
		output.putInt(input.getInt);
		output.putInt(input.getInt);
		output.putInt(input.getInt);
		output.array(input.array);
		return to_return;
	}

	// should find key match pairs that are ready for sending.
	// a select loop?
	Match[] match(SelectionKey[] keys, Pushable[] pushables) {

	}

	// pushes data the standard way, removing the port and address and using them
	// as information, preserves rest in natural order
	void push(void[] data) {
		toPush ~= new Pushable(data);
		SelectionKey[] keys = select.selectedSet;

		foreach(Match matches; match(keys, toPush)) {
			match.push;
		}
	}

	void run() {
		for(; ; ) {
			push = pull;
		}
	}

}

class Server: Thread {
	Reciever reciever;
	Sender sender;
	synchronized ISelector selector;

	Subscriber[int][int] subscribers;
	ThreadConduit[] conduits;
	ThreadConduit notify;
	Encoder encode;

public:
	this(Encoder encode) {
		this(null, encode);
	}

	this(Subscriber[int][int] subscribers_, Encoder encode) {
		// get encoder
		this.encode = encode;

		// setup Senders and Recievers
		sender = new Sender(subscribers, encode, selector);
		reciever = new Reciever(subscribers, encode, selector, sender);

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
		sender.register(upper, lower, subscriber);
		reciever.register(upper, lower, subscriber);
		subscribers[upper][lower] = subscriber;
	}

private:
	void unRegister(int upper, int lower) {
		sender.unRegister(upper, lower);
		sender.unRegister(upper, lower);
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
