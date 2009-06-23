module src.gui.widgets.Editor;

import qt.gui.QPlainTextEdit;
import tango.math.Math : max;
import Integer = tango.text.convert.Integer : toString;
import src.configuration.Configurator;

class EditorManager {
	private:
		Editor[char[]] editors = null;
        ConfigurationManager confMan;
	
	public:
		this() {
            /* Init Configuration manager */
            confMan = new ConfigurationManager("lang/extensions.xml");

            /* Create plain text editor */
            editors["plaintext"] = new Editor(null);
		}
		
		void setText(char[] ext, char[] text) {
			editors[confMan.getConfiguration(ext).name].setPlainText(text);
		}
		
		Editor get(char[] ext) {
            try {
                if(editors[confMan.getConfiguration(ext).name] is null)
                    editors[confMan.getConfiguration(ext).name] = new Editor(confMan.onOpen(ext));
            }
            catch {
                editors[confMan.getConfiguration(ext).name] = new Editor(confMan.onOpen(ext));
            }
			return editors[confMan.getConfiguration(ext).name];
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
        ConfigurationT conf;
	
	public:
		this(ConfigurationT t) {
            conf = t;
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
			
			return 29 + fontMetrics.width("9") * digits;
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
					
					/*
					 * first drawn area displaying debug/bookmark information but also current block
					 * second drawn area displaying line numbers
					 * 
					 */
					//p.drawText(0, top, 12, fontMetrics.height, Qt.AlignmentFlag.AlignCenter, "db");
					p.drawText(13, top, infoArea.width - 21, fontMetrics.height, Qt.AlignmentFlag.AlignRight, number);
				}
				
				block = block.next();
				top = bottom;
				bottom = top + cast(int) blockBoundingRect(block).height;
				blockNumber++;
			}
		}
}