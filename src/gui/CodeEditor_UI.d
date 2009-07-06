module src.gui.CodeEditor_UI;

public {
    import qt.core.QRect;
    import qt.gui.QFontMetrics;
    import qt.gui.QFrame;
    import qt.gui.QHBoxLayout;
    import qt.gui.QTextEdit_ExtraSelection;
    import src.Configurator;
    import src.gui.Editor;
    import src.gui.LinenumberPanel;
    import src.gui.SyntaxHighlighter;
    import tango.math.Math : max;
    import Int = tango.text.convert.Integer : toString;
}

mixin QT_BEGIN_NAMESPACE;

template CodeEditor_UI() {
    private:
        LinenumberPanel linenumberPanel;
        SyntaxHighlighter highlighter;
        Editor editor;
        
        void updatePanelWidth(int newBlockCount) {
            linenumberPanel.setFixedWidth(panelWidth());
        }
        
        void updatePanel(QRect rect, int dy) {
            if (dy > 0) linenumberPanel.scroll(0, dy);
            else linenumberPanel.update(0, rect.y(), linenumberPanel.width(), rect.height());
            
            if (rect.contains(editor.viewport.rect())) updatePanelWidth(0);
        }
        
        void highlightCurrentLine() {
            QTextEdit_ExtraSelection[] extraSelections;
            
            if (!editor.isReadOnly()) {
                QTextEdit_ExtraSelection selection = new QTextEdit_ExtraSelection();
                
                auto lineColor = new QColor(232, 242, 254);
                auto format = selection.format();
                
                format.setBackground(new QBrush(lineColor));
                format.setProperty(QTextFormat.Property.FullWidthSelection, QVariant(true));
                selection.setFormat(format);
                
                auto cursor = editor.textCursor();
                cursor.clearSelection();
                
                selection.setCursor(cursor);
                extraSelections ~= selection;
            }
            
            editor.setExtraSelections(extraSelections);
        }
        
        void setupUi(src.gui.CodeEditor.CodeEditor parent, ConfigurationT conf) {
            editor = new Editor(parent);
            linenumberPanel = new LinenumberPanel(parent);
            highlighter = new SyntaxHighlighter(conf, editor.document());
            
            editor.blockCountChanged.connect(&updatePanelWidth);
            editor.updateRequest.connect(&updatePanel);
            editor.cursorPositionChanged.connect(&highlightCurrentLine);
            
            updatePanelWidth(0);
            highlightCurrentLine();
            
            editor.setFrameShape(QFrame.NoFrame);
            parent.setFrameShape(QFrame.StyledPanel);
            
            auto pLayout = new QHBoxLayout(parent);
            pLayout.setSpacing(0);
            pLayout.setMargin(0);
            
            pLayout.addWidget(linenumberPanel);
            pLayout.addWidget(editor);
        }
        
        int panelWidth() {
            int digits = 1;
            int max = max(1, editor.blockCount());
            
            while (max >= 10) {
                max /= 10;
                ++digits;
            }
            
            return 3 + CodeEditor.fontMetrics().width("9") * digits;
        }
    
    public:
        void linenumberPainter(QPainter p, QPaintEvent e) {
            auto brush = new QBrush(new QColor(47, 85, 164));
            auto block = editor.getFirstVisibleBlock();
            
            int blockNumber = block.blockNumber();
            int top = cast(int) editor.getBlockBoundingGeometry(block).translated(editor.getContentOffset()).top();
            int bottom = top + cast(int) editor.getBlockBoundingRect(block).height();
            
            while (block.isValid() && top <= e.rect.bottom()) {
                if (block.isVisible() && bottom >= e.rect.top())
                    p.drawText(0, top, linenumberPanel.width(), CodeEditor.fontMetrics.height(), Qt.AlignRight, Int.toString(blockNumber + 1));
                
                top = bottom;
                block = block.next();
                bottom = top + cast(int) editor.getBlockBoundingRect(block).height();
                ++blockNumber;
            }
        }
        
        void resizePanel(QResizeEvent e) {
            auto cr = CodeEditor.contentsRect();
            linenumberPanel.setGeometry(QRect(cr.left(), cr.top(), panelWidth(), cr.height()));
        }
        
        void setPlainText(char[] text) {
            editor.setPlainText(text);
        }
}

struct CodeEditor {
    mixin CodeEditor_UI;
    
    QFontMetrics fontMetrics() { return null; }
    QRect contentsRect() { return QRect(); }
}

mixin QT_END_NAMESPACE;