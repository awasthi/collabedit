module src.gui.widgets.Editor;

import qt.gui.QPlainTextEdit;
import qt.gui.QSyntaxHighlighter;
import src.Configurator;
import tango.core.Array : contains;
import tango.math.Math : max;
import tango.io.Stdout;
import tango.time.StopWatch;
import Integer = tango.text.convert.Integer : toString;

class EditorManager {
    private:
        CodeEditor[char[]] editors = null;
        ConfigurationManager confMan;

    public:
        this() {
            /* Init Configuration manager */
            confMan = new ConfigurationManager("syntax/extensions.xml");

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
    
    public:
        this(ConfigurationT _conf, QTextDocument _parent) {
            parent = _parent;
            conf = _conf;
            super(parent);
        }
    
    protected:
        void highlightBlock(char[] text) {
            StopWatch elapsed;
            elapsed.start;
            double i = 0;
            bool commentExists = false;
            if (text.length != 0) {
                foreach (name, pair; conf.pair) {
                    if (name.length > 14 && name[0 .. 16] == "multiLineComment") {
                        commentExists = true;
                    } else {
                        foreach (patt; pair.pattern) {
                            int index = patt.indexIn(text);
                            while (index >= 0) {
                                i += elapsed.stop;
                                if (i < 2) {
                                    elapsed.start;
                                    int length = patt.matchedLength();
                                    if(length <= 0)
                                        break;
                                    setFormat(index, length, pair.format);
                                    index = patt.indexIn(text, index + length);
                                } else { i = 0; break; }
                            }
                        }
                    }
                }
                
                if (commentExists) {
                    setCurrentBlockState(0);
                    
                    int startIndex = 0;
                    if (previousBlockState() != 1)
                        startIndex = conf.pair["multiLineComments"].pattern[0].indexIn(text);
                    
                    while (startIndex >= 0) {
                        int endIndex = conf.pair["multiLineComments"].pattern[1].indexIn(text, startIndex);
                        int commentLength;
                        
                        if (endIndex == -1) {
                            setCurrentBlockState(1);
                            commentLength = text.length - startIndex;
                        } else {
                            commentLength = endIndex - startIndex + conf.pair["multiLineComments"].pattern[1].matchedLength();
                        }
                        
                        setFormat(startIndex, commentLength, conf.pair["multiLineComments"].format);
                        startIndex = conf.pair["multiLineComments"].pattern[0].indexIn(text, startIndex + commentLength);
                    }
                }
            }
        }
}

class CodeEditor : QPlainTextEdit {
    private:
        QPanel panel;
        SyntaxHighlighter highlighter;
        ConfigurationT conf;

    public:
        this(ConfigurationT conf) {
            panel = new QPanel(this);
            highlighter = new SyntaxHighlighter(conf, document());

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