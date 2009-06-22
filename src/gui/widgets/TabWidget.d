module src.gui.widgets.TabWidget;

import qt.gui.QTabWidget;
import src.editor.Editor;
import src.editor.highlightengine.SyntaxHighlighter;

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