module src.highlightengine.TokenList;

import src.editor.highlightengine.Token;

class TokenList {
	public:
		Token[] token;
		
		this(char[] text) {
			foreach (character; text) {
				token ~= new Token(character);
			}
		}
		
		int count() {
			return token.length;
		}
}