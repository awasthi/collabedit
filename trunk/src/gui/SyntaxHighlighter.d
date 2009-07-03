module src.gui.SyntaxHighlighter;

import qt.gui.QSyntaxHighlighter;
import src.Configurator;
import tango.time.StopWatch;

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