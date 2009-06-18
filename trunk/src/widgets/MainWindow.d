module src.widgets.MainWindow;

import qt.gui.QDockWidget;
import qt.gui.QIcon;
import qt.gui.QLabel;
import qt.gui.QMainWindow;
//import src.Resource;
import src.widgets.Chat;
import src.widgets.Compiler;
import src.widgets.ConnectWindow;
import src.widgets.ProjectTree;
import src.widgets.TabWidget;
import src.widgets.UserList;

class MainWindow : QMainWindow {
	private:
		QDockWidget[] docks;
		
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
			
			//auto connect = new ConnectWindow(this);
			//connect.show();
			createDockWidgets();
		}
	
	private:
		void createDockWidgets() {
			docks ~= new QDockWidget(tr("Project"));
			docks ~= new QDockWidget(tr("Users"));
			docks ~= new QDockWidget(tr("Compiler"));
			docks ~= new QDockWidget(tr("Chat"));
			
			docks[0].setWidget(projectTree);
			docks[1].setWidget(userList);
			docks[2].setWidget(compiler);
			docks[3].setWidget(chat);
		}
		
		void setupFrontend() {
			addDockWidget(Qt.LeftDockWidgetArea, docks[0]);
			addDockWidget(Qt.LeftDockWidgetArea, docks[1]);
			addDockWidget(Qt.BottomDockWidgetArea, docks[2]);
			addDockWidget(Qt.BottomDockWidgetArea, docks[3]);
		}
}