module src.gui.widgets.MainWindow;

import qt.gui.QDockWidget;
import qt.gui.QIcon;
import qt.gui.QLabel;
import qt.gui.QLineEdit;
import qt.gui.QMainWindow;
//import src.Resource;
import src.gui.widgets.Chat;
import src.gui.widgets.Compiler;
import src.gui.widgets.ConnectWindow;
import src.gui.widgets.ProjectTree;
import src.gui.widgets.TabWidget;
import src.gui.widgets.UserList;
import src.ResourceManager;

class MainWindow : QMainWindow {
	public:
		ResourceManager resourceManager;
		QLineEdit host, name, password, file;
	
	private:
		ConnectWindow connect;
		
		QDockWidget[] docks;
		
		Chat chat;
		Compiler compiler;
		ProjectTree projectTree;
		TabWidget tabWidget;
		UserList userList;
	
	public:
		this() {
			resourceManager = new ResourceManager();
			
			setWindowIcon(resourceManager.getIcon(ResourceManager.WINDOW_ICON));
			setWindowTitle(tr("collabEdit"));
			
			chat = new Chat();
			compiler = new Compiler();
			projectTree = new ProjectTree();
			tabWidget = new TabWidget();
			userList = new UserList();
			
			auto previewLabel = new QLabel();
			previewLabel.setPixmap(resourceManager.getPixmap(ResourceManager.PREVIEW));
			
			setCentralWidget(previewLabel);
			
			connect = new ConnectWindow(this);
			connect.show();
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
			setCentralWidget(tabWidget);
			createDockWidgets();
			
			addDockWidget(Qt.LeftDockWidgetArea, docks[0]);
			addDockWidget(Qt.LeftDockWidgetArea, docks[1]);
			addDockWidget(Qt.BottomDockWidgetArea, docks[2]);
			addDockWidget(Qt.BottomDockWidgetArea, docks[3]);
		}
		
		void acceptConnection() {
			/*
			 * host: host.text()
			 * name: name.text()
			 * password: password.text()
			 */
			connect.close();
			setupFrontend();
		}
		
		void rejectConnection() {
			// rejected
			connect.close();
			setupFrontend();
		}
}