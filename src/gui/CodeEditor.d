module src.gui.CodeEditor;

private {
    import qt.gui.QFrame;
    import src.Configurator;
    import src.gui.CodeEditor_UI;
}

class CodeEditor : QFrame {
    private:
        mixin CodeEditor_UI;
    
    public:
        this(ConfigurationT conf) {
            setupUi(this, conf);
        }
}