module src.gui.widgets.TabWidget;

import qt.gui.QTabWidget;
import src.EditorManager;

class TabWidget : QTabWidget {
    public:
        this() {
            super();
            setTabsClosable(true);
            
            auto editorManager = new EditorManager();
            addTab(editorManager.get("d"), "D Editor");
        }
}