module src.gui.Editor;

private {
    import qt.gui.QPlainTextEdit;
    import src.gui.CodeEditor;
    import src.gui.Editor_UI;
}

class Editor : QPlainTextEdit {
    private:
        mixin Editor_UI;
    
    public:
        this(CodeEditor parent) {
            super(parent);
            setupUi(this);
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