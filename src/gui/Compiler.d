module src.gui.Compiler;

private import src.gui.Compiler_UI;

class Compiler : QTextEdit {
    public:
        this(QWidget parent = null) {
            super(parent);
            setupUi(this);
        }
    
    private:
        mixin Compiler_UI;
}