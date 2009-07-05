module src.gui.TabWidget;

private {
    import src.EditorManager;
    import src.gui.TabWidget_UI;
}

class TabWidget : QTabWidget {
    public:
        this(QWidget parent = null) {
            super(parent);
            setupUi(this);
            
            auto editorManager = new EditorManager();
            addTab(editorManager.get("d"), "D Editor");
        }
    
    private:
        mixin TabWidget_UI;
}