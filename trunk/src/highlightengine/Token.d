module src.highlightengine.Token;

class Token {
	private:
		char token;
	
	public:
		static enum {
			None,
			Number,
			Delimiter,
			Operator
		}
		
		this(char token) {
			this.token = token;
		}
		
		int type() {
			switch (token) {
				case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9': return Number;
				case '"':
				case '\'': return Delimiter;
				case '!':
				case '(':
				case ')':
				case '?':
				case '[':
				case ']':
				case '<':
				case '=':
				case '>': return Operator;
				default:
			}
			
			return None;
		}
}