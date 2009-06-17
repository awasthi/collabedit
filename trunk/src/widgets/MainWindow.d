module src.widgets.MainWindow;

import qt.gui.QDockWidget;
import qt.gui.QIcon;
import qt.gui.QLabel;
import qt.gui.QMainWindow;
//import src.Resource;
import src.widgets.Chat;
import src.widgets.Compiler;
import src.widgets.ProjectTree;
import src.widgets.TabWidget;
import src.widgets.UserList;

class MainWindow : QMainWindow {
	private:
		Chat chat;
		Compiler compiler;
		ProjectTree projectTree;
		TabWidget tabWidget;
		UserList userList;
	
	public:
		this() {
			//setWindowIcon(new QIcon(":icon.png"));
			setWindowTitle(tr("collabEdit"));
			
			chat = new Chat();
			compiler = new Compiler();
			projectTree = new ProjectTree();
			tabWidget = new TabWidget();
			userList = new UserList();
			
			setCentralWidget(tabWidget);
			createDockWidgets();
		}
	
	private:
		void createDockWidgets() {
			auto projectDock = new QDockWidget(tr("Project"));
			projectDock.setWidget(projectTree);
			
			auto userListDock = new QDockWidget(tr("Users"));
			userListDock.setWidget(userList);
			
			auto compilerDock = new QDockWidget(tr("Compiler"));
			compilerDock.setWidget(compiler);
			
			auto chatDock = new QDockWidget(tr("Chat"));
			chatDock.setWidget(chat);
			
			addDockWidget(Qt.LeftDockWidgetArea, projectDock);
			addDockWidget(Qt.LeftDockWidgetArea, userListDock);
			addDockWidget(Qt.BottomDockWidgetArea, compilerDock);
			addDockWidget(Qt.BottomDockWidgetArea, chatDock);
		}
}