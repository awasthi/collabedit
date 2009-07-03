module src.gui.widgets.CodeEditor;

import qt.gui.QFrame;
import qt.gui.QHBoxLayout;
import qt.gui.QTextEdit_ExtraSelection;
import src.Configurator;
import src.gui.SyntaxHighlighter;
import src.gui.widgets.Editor;
import src.gui.widgets.LinenumberPanel;
import tango.math.Math : max;
import Int = tango.text.convert.Integer : toString;

class CodeEditor : QFrame {
    private:
        LinenumberPanel linenumberPanel;
        SyntaxHighlighter highlighter;
        ConfigurationT conf;
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

    public:
        this(ConfigurationT conf) {
            editor = new Editor(this);
            linenumberPanel = new LinenumberPanel(this);
            highlighter = new SyntaxHighlighter(conf, editor.document());
            
            editor.blockCountChanged.connect(&updatePanelWidth);
            editor.updateRequest.connect(&updatePanel);
            editor.cursorPositionChanged.connect(&highlightCurrentLine);
            
            updatePanelWidth(0);
            highlightCurrentLine();
            
            editor.setFrameShape(QFrame.NoFrame);
            setFrameShape(QFrame.StyledPanel);
            
            auto pLayout = new QHBoxLayout(this);
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
            
            return 3 + fontMetrics().width("9") * digits;
        }
        
        void linenumberPainter(QPainter p, QPaintEvent e) {
            auto brush = new QBrush(new QColor(47, 85, 164));
            auto block = editor.getFirstVisibleBlock();
            
            int blockNumber = block.blockNumber();
            int top = cast(int) editor.getBlockBoundingGeometry(block).translated(editor.getContentOffset()).top();
            int bottom = top + cast(int) editor.getBlockBoundingRect(block).height();
            
            while (block.isValid() && top <= e.rect.bottom()) {
                if (block.isVisible() && bottom >= e.rect.top())
                    p.drawText(0, top, linenumberPanel.width(), fontMetrics.height(), Qt.AlignRight, Int.toString(blockNumber + 1));
                
                top = bottom;
                block = block.next();
                bottom = top + cast(int) editor.getBlockBoundingRect(block).height();
                ++blockNumber;
            }
        }
        
        void resizePanel(QResizeEvent e) {
            auto cr = contentsRect();
            linenumberPanel.setGeometry(QRect(cr.left(), cr.top(), panelWidth(), cr.height()));
        }
        
        void setPlainText(char[] text) {
            editor.setPlainText(text);
        }
}