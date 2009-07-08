module src.gui.Editor_UI;

public import qt.gui.QPlainTextEdit;

mixin QT_BEGIN_NAMESPACE;

template Editor_UI() {
    private:
        void setupUi(QPlainTextEdit parent) {
            parent.setLineWrapMode(QPlainTextEdit_LineWrapMode.NoWrap);
        }
}

struct Editor {
    mixin Editor_UI;
}

mixin QT_END_NAMESPACE;