module src.gui.widgets.Editor;

import qt.gui.QTextEdit;
import tango.io.FilePath;
import tango.io.device.File;
import tango.math.Math;
import Integer = tango.text.convert.Integer;

class Editor : QTextEdit {
	public:
		char[] ext;
		
		this(char[] fileName = "") {
			setViewportMargins(50, 0, 0, 0);
			verticalScrollBar.valueChanged.connect(&update);
			textChanged.connect(&update);
			
			if (fileName.length) {
				setText(cast(char[]) File.get(fileName));
				ext = (new FilePath(fileName)).ext;
			}
		}
		
		bool event(QEvent event) {
			if (event.type == QEvent.Paint) {
				scope p = new QPainter(this);
				
				int contentsY = verticalScrollBar.value;
				int pageBottom = contentsY + viewport.height;
				int m_lineNumber = 1;
				
				auto fm = fontMetrics();
				int ascent = fm.ascent + 1;
				
				for (QTextBlock block = document.begin(); block.isValid(); block = block.next(), m_lineNumber++) {
					auto layout = block.layout();
					auto boundingRect = layout.boundingRect();
					auto position = layout.position();
					
					if (position.y + boundingRect.height < contentsY)
						continue;
					
					if (position.y > pageBottom)
						break;
					
					char[] txt = Integer.toString(m_lineNumber);
					auto point = QPoint(cast(int) (50 - fm.width(txt) - 2), cast(int) (round(position.y) - contentsY + ascent));
					p.drawText(point, txt);
				}
			}
			
			return super.event(event);
		}
}