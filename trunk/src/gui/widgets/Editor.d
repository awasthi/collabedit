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

class InfoArea : QWidget {
	private:
		Editor editor;
	
	public:
		this(Editor editor) {
			this.editor = editor;
			setParent(editor);
		}
		
		QSize sizeHint() {
			return QSize(editor.infoAreaWidth(), 0);
		}
	
	protected:
		void paintEvent(QPaintEvent event) {
			editor.infoAreaPaintEvent(event);
		}
}

class Editor : QPlainTextEdit {
	private:
		InfoArea infoArea;
	
	public:
		this() {
			infoArea = new InfoArea(this);
			
			blockCountChanged.connect(&updateInfoAreaWidth);
			updateRequest.connect(&updateInfoArea);
			updateInfoAreaWidth(0);
			
			//verticalScrollBar.valueChanged.connect(&update);
			textChanged.connect(&update);
		}
		
		int infoAreaWidth() {
			int digits = 1;
			int max = max(1, blockCount());
			
			while (max >= 10) {
				max /= 10;
				digits++;
			}
			
			return 60 + fontMetrics.width("9") * digits;
		}
		
		void updateInfoAreaWidth(int newBlockCount) {
			setViewportMargins(infoAreaWidth(), 0, 0, 0);
		}
		
		void updateInfoArea(QRect rec, int dy) {
			if (dy > 0)
				infoArea.scroll(0, dy);
			else
				infoArea.update(0, rect.y, infoArea.width, rect.height);
			
			if (rect.contains(viewport.rect()))
				updateInfoAreaWidth(0);
		}
		
		void resizeEvent(QResizeEvent e) {
			super.resizeEvent(e);
			
			auto cr = contentsRect();
			infoArea.setGeometry(QRect(cr.left, cr.top, infoAreaWidth(), cr.height));
		}
		
		void infoAreaPaintEvent(QPaintEvent event) {
			scope p = new QPainter(infoArea);
			
			QTextBlock block = firstVisibleBlock();
			int blockNumber = block.blockNumber();
			int top = cast(int) blockBoundingGeometry(block).translated(contentOffset()).top;
			int bottom = top + cast(int) blockBoundingRect(block).height;
			
			while (block.isValid && top <= event.rect.bottom) {
				if (block.isVisible && bottom >= event.rect.top) {
					char[] number = Integer.toString(blockNumber + 1);
					
					p.drawText(3, top, 16, fontMetrics.height, Qt.AlignmentFlag.AlignCenter, "c");
					p.drawText(22, top, 16, fontMetrics.height, Qt.AlignmentFlag.AlignCenter, "d");
					p.drawText(41, top, 16, fontMetrics.height, Qt.AlignmentFlag.AlignCenter, "b");
					p.drawText(60, top, infoArea.width - 60, fontMetrics.height, Qt.AlignmentFlag.AlignRight, number);
				}
				
				block = block.next();
				top = bottom;
				bottom = top + cast(int) blockBoundingRect(block).height;
				blockNumber++;
			}
		}
}