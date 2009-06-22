module src.gui.widgets.TabWidget;

import qt.gui.QTabWidget;
import src.gui.widgets.Editor;

class TabWidget : QTabWidget {
	public:
		this() {
			super();
			setTabsClosable(true);
			
			auto editorManager = new EditorManager();
			addTab(editorManager.get(Editor_Syntax.PlainText), "Sample PlainText Editor");
			addTab(editorManager.get(Editor_Syntax.D), "Sample D Editor");
		}
}