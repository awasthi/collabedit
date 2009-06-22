module src.highlightengine.SyntaxHighlighter;

private {
    import qt.gui.QColor;
    import qt.gui.QSyntaxHighlighter;
    import src.editor.Editor;
    import src.configuration.Configurator;
    import TUtil = tango.text.Util;
}

class SyntaxHighlighter : QSyntaxHighlighter {
private:


public:
    this(Editor editor) {
        super(editor.document);
    }

    void highlightBlock(char[] text) {
    }
}