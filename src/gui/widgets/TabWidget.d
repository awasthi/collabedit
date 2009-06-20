module src.gui.widgets.TabWidget;

import qt.gui.QTabWidget;
import src.gui.widgets.Editor;
import src.highlightengine.SyntaxHighlighter;

class TabWidget : QTabWidget {
	public:
		this() {
			super();
			
			auto sampleEditor = new Editor();
			auto highlighter = new SyntaxHighlighter(sampleEditor);
			
			setTabsClosable(true);
			addTab(sampleEditor, "Sample Editor");
		}
}