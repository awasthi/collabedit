module src.gui.widgets.TabWidget;

import qt.gui.QTabWidget;
import src.gui.widgets.Editor;

class TabWidget : QTabWidget {
	public:
		this() {
			super();
			
			setTabsClosable(true);
			addTab(new Editor(), "Sample Editor");
		}
}