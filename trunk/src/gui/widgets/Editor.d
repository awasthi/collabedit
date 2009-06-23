module src.gui.widgets.Editor;

import qt.gui.QPlainTextEdit;
import qt.gui.QSyntaxHighlighter;
import src.configuration.Configurator;
import tango.core.Array : contains;
import tango.math.Math : max;
import tango.io.Stdout;
import Integer = tango.text.convert.Integer : toString;

class EditorManager {
    private:
        CodeEditor[char[]] editors = null;
        ConfigurationManager confMan;

    public:
        this() {
            /* Init Configuration manager */
            confMan = new ConfigurationManager("lang/extensions.xml");

            /* Create plain text editor */
            editors["plaintext"] = new CodeEditor(null);
        }

        void setText(char[] ext, char[] text) {
            get(ext).setPlainText(text);
        }

        CodeEditor get(char[] ext) {
            try {
                if(editors[confMan.getConfiguration(ext).name] is null)
                    editors[confMan.getConfiguration(ext).name] = new CodeEditor(confMan.onOpen(ext));
            }
            catch {
                editors[confMan.getConfiguration(ext).name] = new CodeEditor(confMan.onOpen(ext));
            }
            return editors[confMan.getConfiguration(ext).name];
        }
}

class QPanel : QWidget {
    private:
        CodeEditor editor;

    public:
        this(CodeEditor editor) {
            this.editor = editor;
            setParent(editor);
        }

        QSize sizeHint() {
            return QSize(editor.panelWidth(), 0);
        }

    protected:
        void paintEvent(QPaintEvent event) {
            editor.panelPaintEvent(event);
        }
}

class SyntaxHighlighter : QSyntaxHighlighter {
    private:
        ConfigurationT conf;
        QTextDocument parent;

        enum State {
            NormalState = -1,
            InsideComment,
            InsideDeliminer
        }

    public:
        this(ConfigurationT conf, QTextDocument parent) {
            this.conf = conf;
            this.parent = parent;

            super(parent);
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

    protected:
        void highlightBlock(char[] text) {
            int state = previousBlockState();
            int start = 0;
            int len = 0;

            for (int i = 0; i < text.length; i++) {
                if(len == i) len--;
                if (contains(conf.keywords["delimiters"], mid(text, start, len))) {
                    setFormat(start, len, conf.styles["deliminers"]);
                    start = i;
                } else if (contains(conf.keywords["operators"], mid(text, start, len))) {
                    setFormat(start, len, conf.styles["operator"]);
                    start = i;
                } else if (contains(conf.keywords["comment"], mid(text, start, len))) {
                    setFormat(start, len, conf.styles["comment"]);
                    start = i;
                } else if (contains(conf.keywords["endComment"], mid(text, start, len))) {
                    setFormat(start, len, conf.styles["comment"]);
                    start = i;
                } else if (contains(conf.keywords["commentLine"], mid(text, start, len))) {
                    setFormat(start, len, conf.styles["commentLine"]);
                    start = i;
                } else if (contains(conf.keywords["words1"], mid(text, start, len))) {
                    setFormat(start, len, conf.styles["words1"]);
                    start = i;
                } else if (contains(conf.keywords["words2"], mid(text, start, len))) {
                    setFormat(start, len, conf.styles["words2"]);
                    start = i;
                } else if (contains(conf.keywords["words3"], mid(text, start, len))) {
                    setFormat(start, len, conf.styles["words3"]);
                    start = i;
                } else if (contains(conf.keywords["words4"], mid(text, start, len))) {
                    setFormat(start, len, conf.styles["words4"]);
                    start = i;
                } else {
                    start++;
                }
            }

            setCurrentBlockState(state);
        }
}

class CodeEditor : QPlainTextEdit {
    private:
        QPanel panel;
        SyntaxHighlighter highlighter;

    public:
        this(ConfigurationT t) {
            panel = new QPanel(this);
            highlighter = new SyntaxHighlighter(t, document());

            blockCountChanged.connect(&updateInfoAreaWidth);
            updateRequest.connect(&updateInfoArea);
            updateInfoAreaWidth(0);
            
            //verticalScrollBar.valueChanged.connect(&update);
            textChanged.connect(&update);
        }

        int panelWidth() {
            int digits = 1;
            int max = max(1, blockCount());

            while (max >= 10) {
                max /= 10;
                digits++;
            }

            return 29 + fontMetrics.width("9") * digits;
        }

        void updatePanelWidth(int newBlockCount) {
            setViewportMargins(panelWidth(), 0, 0, 0);
        }

        void updatePanel(QRect rec, int dy) {
            if (dy > 0)
                panel.scroll(0, dy);
            else
                panel.update(0, rect.y, panel.width, rect.height);

            if (rect.contains(viewport.rect()))
                updatePanelWidth(0);
        }

        void resizeEvent(QResizeEvent e) {
            super.resizeEvent(e);

            auto cr = contentsRect();
            panel.setGeometry(QRect(cr.left, cr.top, panelWidth(), cr.height));
        }

        void panelPaintEvent(QPaintEvent event) {
            scope p = new QPainter(panel);

            QTextBlock block = firstVisibleBlock();
            int blockNumber = block.blockNumber();
            int top = cast(int) blockBoundingGeometry(block).translated(contentOffset()).top;
            int bottom = top + cast(int) blockBoundingRect(block).height;

            while (block.isValid && top <= event.rect.bottom) {
                if (block.isVisible && bottom >= event.rect.top) {
                    /*
                    * first drawn area displaying debug/bookmark information but also current block
                    * second drawn area displaying line numbers
                    *
                    */
                    //p.drawText(0, top, 12, fontMetrics.height, Qt.AlignmentFlag.AlignCenter, "db");
                    p.drawText(13, top, panel.width - 21, fontMetrics.height, Qt.AlignmentFlag.AlignRight, Integer.toString(blockNumber + 1));
                }

                block = block.next();
                top = bottom;
                bottom = top + cast(int) blockBoundingRect(block).height;
                blockNumber++;
            }
        }

        void updateInfoAreaWidth(int newBlockCount) {
            setViewportMargins(infoAreaWidth(), 0, 0, 0);
        }
   
        void updateInfoArea(QRect rec, int dy) {
            if (dy > 0)
                panel.scroll(0, dy);
            else
                panel.update(0, rect.y, panel.width, rect.height);
    
                if (rect.contains(viewport.rect()))
            updateInfoAreaWidth(0);
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
}