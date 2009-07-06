module src.gui.Compiler;

private import src.gui.Compiler_UI;

class Compiler : QTextEdit {
    private:
        mixin Compiler_UI;
    
    public:
        this(QWidget parent = null) {
            super(parent);
            setupUi(this);
        }
}