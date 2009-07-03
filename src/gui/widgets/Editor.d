module src.gui.widgets.Editor;

import qt.gui.QPlainTextEdit;
import src.gui.widgets.CodeEditor;

class Editor : QPlainTextEdit {
    public:
        this(CodeEditor parent) {
            super(parent);
        }
        
        QTextBlock getFirstVisibleBlock() {
            return firstVisibleBlock();
        }
        
        QRectF getBlockBoundingGeometry(QTextBlock block) {
            return blockBoundingGeometry(block);
        }
        
        QRectF getBlockBoundingRect(QTextBlock block) {
            return blockBoundingRect(block);
        }
        
        QPointF getContentOffset() {
            return contentOffset();
        }
}