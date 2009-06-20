module src.highlightengine.SyntaxHighlighter;

import qt.gui.QColor;
import qt.gui.QSyntaxHighlighter;
import src.gui.widgets.Editor;
import src.highlightengine.Token;
import src.highlightengine.TokenList;

class SyntaxHighlighter : QSyntaxHighlighter {
	private:
		enum State {
			NormalState = -1,
			InsideDeliminer,
			InsideComment
		}
	
	public:
		this(Editor editor) {
			super(editor.document);
		}
		
		void highlightBlock(char[] text) {
			auto tokenList = new TokenList(text);
			int state = previousBlockState();
			int start = 0;
			
			for (int i = 0; i < tokenList.count(); i++) {
				if (state == State.InsideComment) {
					if (mid(text, i, 2) == "*/") {
						state = State.NormalState;
						setFormat(start, i - start + 2, new QColor(0, 128, 0));
					}
				} else {
					if (mid(text, i, 2) == "//") {
						setFormat(i, text.length - i, new QColor(0, 128, 0));
					} else if (mid(text, i, 2) == "/*") {
						start = i;
						state = State.InsideComment;
					} else {
						auto token = tokenList.token[i];
						
						switch (token.type()) {
							case Token.Delimiter:
								if (state == State.InsideDeliminer) {
									state = State.NormalState;
									setFormat(start, i - start + 1, new QColor(175, 43, 255));
								} else {
									start = i;
									state = State.InsideDeliminer;
								}
								break;
							case Token.Number:
								setFormat(i, 1, new QColor(217, 0, 108));
								break;
							case Token.Operator:
								setFormat(i, 1, new QColor(0, 0, 0));
								break;
							default:
								// check for words1 like "abstract" to set its format to QColor(0, 0, 255) and bold!
								// check also for words2 like "bool" to set its format to QColor(0, 0, 255) and bold!
								// check also for words3...and so on
								// ...words4...
						}
					}
				}
			}
			
			if (state == State.InsideDeliminer)
				setFormat(start, text.length - start, new QColor(175, 43, 255));
			else if (state == State.InsideComment)
				setFormat(start, text.length - start, new QColor(0, 128, 0));
			
			setCurrentBlockState(state);
		}
	
	private:
		char[] mid(char[] source, uint index, uint len) {
			uint slen = source.length;
			
			if (slen == 0 || index >= slen)
				return "";
			
			if (len > slen - index)
				len = slen - index;
			
			if (index == 0 && len == slen)
				return source;
			
			return source[index .. index + len];
		}
}