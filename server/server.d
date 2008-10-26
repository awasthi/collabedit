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
			auto conduits = new ThreadConduit;
			this(conduits);
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
			for(; ; ) {
				notifiable.read(to_read);
				if(to_read == "alive") {
					notify.write("alive");
				}
				notifiable.clear();

				run();
			}
		}

		//all subclasses implement so that it deletes itself after restarting
		abstract Subscriber restart();

}

private class Handler: Thread { // this will connect and listen on certain ports
	// must modify it to actually do this
	public ThreadConduit notifiable, notify;
	public Subscriber[int][int] subscribers;
	public uint port;
	Sender sender;

	public this(uint port, Sender sender) {
		this.port = port;
		notifiable = new ThreadConduit;
		this.sender = sender;
	}

	public void add(Subscriber subscriber) {
		subscribers[subscriber.upper][subscriber.lower] = subscriber;
	}
}

//must fix this and above to use encode
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
										subscriber.port, sender);
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
			Subscriber[int][int] temp;
			uint portTemp;
			for(; ; ) { //monitor the handlers here and restart them if necessary
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

						handle = new Handler(portTemp, sender);
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
								reciever.sleep(1);
								conduits[0] = subscriber.information;
								conduits[0].clear;
								subscriber = subscriber.restart;;
							}
						}
					}
				}
			}
		}
}
