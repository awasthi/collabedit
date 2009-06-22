module src.gui.widgets.MainWindow;

import qt.gui.QAction;
import qt.gui.QDockWidget;
import qt.gui.QIcon;
import qt.gui.QLabel;
import qt.gui.QLineEdit;
import qt.gui.QMainWindow;
import qt.gui.QMessageBox;
//import src.Resource;
import src.gui.widgets.Chat;
import src.gui.widgets.Compiler;
import src.gui.widgets.ConnectWindow;
import src.editor.Editor;
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
		
		QAction[] actions;
		QDockWidget[] docks;
		
		Chat chat;
		Compiler compiler;
		ProjectTree projectTree;
		TabWidget tabWidget;
		UserList userList;
	
	public:
		this() {
			resourceManager = new ResourceManager(style);
			
			setWindowIcon(resourceManager.getIcon(ResourceManager.WINDOW_ICON));
			setWindowTitle(tr("collabEdit"));
			
			chat = new Chat();
			compiler = new Compiler();
			projectTree = new ProjectTree();
			tabWidget = new TabWidget();
			userList = new UserList();
			
			auto previewLabel = new QLabel();
			previewLabel.setPixmap(resourceManager.getPixmap(ResourceManager.PREVIEW));
			previewLabel.setAlignment(Qt.AlignCenter);
			
			setCentralWidget(previewLabel);
			
			connect = new ConnectWindow(this);
			openConnection();
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
		
		void createActions() {
			actions ~= new QAction(tr("&Open Connection"), this);
			actions ~= new QAction(tr("&New"), this);
			actions ~= new QAction(tr("&Save"), this);
			actions ~= new QAction(tr("E&xit"), this);
			actions ~= new QAction(tr("&Undo"), this);
			actions ~= new QAction(tr("&Redo"), this);
			actions ~= new QAction(tr("Cu&t"), this);
			actions ~= new QAction(tr("&Copy"), this);
			actions ~= new QAction(tr("&Paste"), this);
			actions ~= new QAction(tr("&About"), this);
			
			actions[0].setShortcut(tr("Ctrl+O"));
			actions[0].setStatusTip(tr("Connect to a server"));
			actions[0].triggered.connect(&openConnection);
			
			actions[1].setShortcut(tr("Ctrl+N"));
			actions[1].setStatusTip(tr("Create a new file"));
			actions[1].triggered.connect(&newFile);
			
			actions[2].setShortcut(tr("Ctrl+S"));
			actions[2].setStatusTip(tr("Save the document"));
			actions[2].triggered.connect(&save);
			
			actions[3].setShortcut(tr("Ctrl+Q"));
			actions[3].setStatusTip(tr("Exit the application"));
			actions[3].triggered.connect(&close);
			
			actions[4].setShortcut(tr("Ctrl+Z"));
			actions[4].setStatusTip(tr("Undo last change"));
			//actions[4].triggered.connect(&undo);
			
			actions[5].setShortcut(tr("Ctrl+Y"));
			actions[5].setStatusTip(tr("Redo last undone change"));
			//actions[5].triggered.connect(&redo);
			
			actions[6].setShortcut(tr("Ctrl+X"));
			actions[6].setStatusTip(tr("Cut the current selection's contents to the clipboard"));
			//actions[6].triggered.connect(&cut);
			
			actions[7].setShortcut(tr("Ctrl+C"));
			actions[7].setStatusTip(tr("Copy the current selection's contents to the clipboard"));
			//actions[7].triggered.connect(&copy);
			
			actions[8].setShortcut(tr("Ctrl+V"));
			actions[8].setStatusTip(tr("Paste the clipboard's contents into the current selection"));
			//actions[8].triggered.connect(&paste);
			
			actions[9].setStatusTip(tr("About collabEdit"));
			actions[9].triggered.connect(&about);
		}
		
		void setupFrontend() {
			createActions();
			createMenus();
			createToolBars();
			
			new Editor();
			
			setCentralWidget(tabWidget);
			createDockWidgets();
			
			addDockWidget(Qt.LeftDockWidgetArea, docks[0]);
			addDockWidget(Qt.LeftDockWidgetArea, docks[1]);
			addDockWidget(Qt.BottomDockWidgetArea, docks[2]);
			addDockWidget(Qt.BottomDockWidgetArea, docks[3]);
			
			statusBar.showMessage(tr("Ready"));
		}
		
		void createMenus() {
			auto menu = menuBar.addMenu(tr("&File"));
			
			menu.addAction(actions[0]);
			menu.addSeparator();
			menu.addAction(actions[1]);
			menu.addAction(actions[2]);
			menu.addSeparator();
			menu.addAction(actions[3]);
			
			menu = menuBar.addMenu(tr("&Edit"));
			
			menu.addAction(actions[4]);
			menu.addAction(actions[5]);
			menu.addSeparator();
			menu.addAction(actions[6]);
			menu.addAction(actions[7]);
			menu.addAction(actions[8]);
			
			menu = menuBar.addMenu(tr("&View"));
			
			//menu.addAction();
			
			menu = menuBar.addMenu(tr("&?"));
			
			menu.addAction(actions[9]);
		}
		
		void createToolBars() {
			auto bar = addToolBar(tr("Connection"));
			bar.addAction(actions[0]);
			
			bar = addToolBar(tr("File"));
			bar.addAction(actions[1]);
			bar.addAction(actions[2]);
		}
		
		void acceptConnection() {
			/*
			 * host: host.text()
			 * name: name.text()
			 * password: password.text()
			 */
			connect.close();
			if (!actions.length) setupFrontend();
		}
		
		void rejectConnection() {
			connect.close();
		}
		
		void openConnection() {
			connect.show();
		}
		
		void newFile() {
			
		}
		
		void save() {
			
		}
		
		void about() {
			QMessageBox.about(this, tr("About collabEdit"), tr("..."));
		}
}