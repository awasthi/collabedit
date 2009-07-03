module src.gui.widgets.LinenumberPanel;

import qt.gui.QPaintEvent;
import src.gui.widgets.CodeEditor;
import src.gui.widgets.Panel;

class LinenumberPanel : Panel {
    public:
        this(CodeEditor parent) {
            super(parent);
        }
    
    protected:
        void paintEvent(QPaintEvent e) {
            scope p = new QPainter(this);
            parent.linenumberPainter(p, e);
        }
        
        void resizeEvent(QResizeEvent e) {
            super.resizeEvent(e);
            parent.resizePanel(e);
        }
}