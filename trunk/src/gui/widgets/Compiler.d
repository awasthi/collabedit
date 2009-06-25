module src.gui.widgets.Compiler;

import qt.gui.QTextEdit;

class Compiler : QTextEdit {
    public:
        this() {
            super();
            
            setReadOnly(true);
        }
}