module src.gui.widgets.Editor;

import qt.gui.QTextEdit;
import tango.io.FilePath;
import tango.io.device.File;
import tango.math.Math : round;
import Integer = tango.text.convert.Integer : toString;
import src.highlightengine.SyntaxHighlighter;

static enum Editor_Syntax {
	PlainText,
	D
}

class EditorManager {
	private:
		Editor[] editors;
	
	public:
		this() {
			for (int i = 0; i < Editor_Syntax.sizeof; i++) {
				editors ~= new Editor();
				new SyntaxHighlighter(i, editors[i]);
			}
		}
		
		Editor get(int syntax) {
			return editors[syntax];
		}
}

class Editor : QTextEdit {
	public:
		this() {
			setViewportMargins(50, 0, 0, 0);
			verticalScrollBar.valueChanged.connect(&update);
			textChanged.connect(&update);
		}
		
		void setFile(char[] fileName) {
			setText(cast(char[]) File.get(fileName));
		}
		
		bool event(QEvent event) {
			if (event.type == QEvent.Paint) {
				scope p = new QPainter(this);
				
				int contentsY = verticalScrollBar.value;
				int pageBottom = contentsY + viewport.height;
				int m_lineNumber = 1;
				
				auto fm = fontMetrics();
				int ascent = fm.ascent + 1;
				
				for (QTextBlock block = document.begin; block.isValid; block = block.next(), m_lineNumber++) {
					auto layout = block.layout();
					auto boundingRect = layout.boundingRect();
					auto position = layout.position();
					
					if (position.y + boundingRect.height < contentsY)
						continue;
					
					if (position.y > pageBottom)
						break;
					
					char[] txt = Integer.toString(m_lineNumber);
					p.drawText(QPoint(cast(int) (50 - fm.width(txt) - 2), cast(int) (round(position.y) - contentsY + ascent)), txt);
				}
			}
			
			return super.event(event);
		}
}