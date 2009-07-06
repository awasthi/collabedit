module src.gui.CodeEditor;

import qt.gui.QFrame;
import src.Configurator;
import src.gui.CodeEditor_UI;

class CodeEditor : QFrame {
    public:
        this(ConfigurationT conf) {
            setupUi(this, conf);
        }
    
    private:
        mixin CodeEditor_UI;
}