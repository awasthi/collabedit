module src.gui.Panel;

import qt.gui.QWidget;
import src.gui.CodeEditor;

class Panel : QWidget {
    public:
        CodeEditor parent;
        
        this(CodeEditor parent) {
            this.parent = parent;
            super(parent);
        }
}