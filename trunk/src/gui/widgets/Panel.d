module src.gui.widgets.Panel;

import qt.gui.QWidget;
import src.gui.widgets.CodeEditor;

class Panel : QWidget {
    public:
        CodeEditor parent;
        
        this(CodeEditor parent) {
            this.parent = parent;
            super(parent);
        }
}