module src.gui.Compiler_UI;

public {
    import qt.gui.QTextEdit;
    import qt.gui.QWidget;
}

mixin QT_BEGIN_NAMESPACE;

template Compiler_UI() {
    public void setupUi(QTextEdit parent) {
        parent.setReadOnly(true);
    }
}

struct Compiler {
    mixin Compiler_UI;
}

mixin QT_END_NAMESPACE;