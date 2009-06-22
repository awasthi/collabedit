module src.gui.widgets.Editor;

import qt.gui.QPlainTextEdit;
import tango.math.Math : max;
import Integer = tango.text.convert.Integer : toString;

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
				//new SyntaxHighlighter(i, editors[i]);
			}
		}
		
		Editor get(int syntax) {
			return editors[syntax];
		}
}

class LineNumberArea : QWidget {
	private:
		Editor editor;
	
	public:
		this(Editor editor) {
			this.editor = editor;
			setParent(editor);
		}
		
		QSize sizeHint() {
			return QSize(editor.lineNumberAreaWidth(), 0);
		}
	
	protected:
		void paintEvent(QPaintEvent event) {
			editor.lineNumberAreaPaintEvent(event);
		}
}

class Editor : QPlainTextEdit {
	private:
		LineNumberArea lineNumberArea;
	
	public:
		this() {
			lineNumberArea = new LineNumberArea(this);
			
			blockCountChanged.connect(&updateLineNumberAreaWidth);
			updateRequest.connect(&updateLineNumberArea);
			updateLineNumberAreaWidth(0);
			
			verticalScrollBar.valueChanged.connect(&update);
			textChanged.connect(&update);
		}
		
		int lineNumberAreaWidth() {
			int digits = 1;
			int max = max(1, blockCount());
			
			while (max >= 10) {
				max /= 10;
				digits++;
			}
			
			return 3 + fontMetrics.width("9") * digits;
		}
		
		void updateLineNumberAreaWidth(int newBlockCount) {
			setViewportMargins(lineNumberAreaWidth(), 0, 0, 0);
		}
		
		void updateLineNumberArea(QRect rec, int dy) {
			if (dy > 0)
				lineNumberArea.scroll(0, dy);
			else
				lineNumberArea.update(0, rect.y, lineNumberArea.width, rect.height);
			
			if (rect.contains(viewport.rect()))
				updateLineNumberAreaWidth(0);
		}
		
		void resizeEvent(QResizeEvent e) {
			super.resizeEvent(e);
			
			auto cr = contentsRect();
			lineNumberArea.setGeometry(QRect(cr.left, cr.top, lineNumberAreaWidth(), cr.height));
		}
		
		void lineNumberAreaPaintEvent(QPaintEvent event) {
			scope p = new QPainter(lineNumberArea);
			
			QTextBlock block = firstVisibleBlock();
			int blockNumber = block.blockNumber();
			int top = cast(int) blockBoundingGeometry(block).translated(contentOffset()).top;
			int bottom = top + cast(int) blockBoundingRect(block).height;
			
			while (block.isValid && top <= event.rect.bottom) {
				if (block.isVisible && bottom >= event.rect.top) {
					char[] number = Integer.toString(blockNumber + 1);
					p.drawText(0, top, lineNumberArea.width, fontMetrics.height, Qt.AlignmentFlag.AlignRight, number);
				}
				
				block = block.next();
				top = bottom;
				bottom = top + cast(int) blockBoundingRect(block).height;
				blockNumber++;
			}
		}
}