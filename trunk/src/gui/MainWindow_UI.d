module src.gui.MainWindow_UI;

public {
    import qt.gui.QDockWidget;
    import qt.gui.QLabel;
    import qt.gui.QMainWindow;
    import qt.gui.QMessageBox;
    import src.ResourceManager;
    import src.gui.Chat;
    import src.gui.Compiler;
    import src.gui.ProjectTree;
    import src.gui.TabWidget;
    import src.gui.UserList;
}

mixin QT_BEGIN_NAMESPACE;

template MainWindow_UI() {
    private:
        ResourceManager resourceManager;
        QMainWindow parent;
        QAction[] actions;
        QMenu viewMenu;
        
        Chat chat;
        Compiler compiler;
        ProjectTree projectTree;
        TabWidget tabWidget;
        UserList userList;
        
        QDockWidget[] docks;
        
        void createActions() {
            actions ~= new QAction(tr("&Open Connection"), parent);
            actions ~= new QAction(tr("&New"), parent);
            actions ~= new QAction(tr("&Save"), parent);
            actions ~= new QAction(tr("E&xit"), parent);
            actions ~= new QAction(tr("&Undo"), parent);
            actions ~= new QAction(tr("&Redo"), parent);
            actions ~= new QAction(tr("Cu&t"), parent);
            actions ~= new QAction(tr("&Copy"), parent);
            actions ~= new QAction(tr("&Paste"), parent);
            actions ~= new QAction(tr("&About"), parent);
            
            actions[0].setShortcut(tr("Ctrl+O"));
            actions[0].setStatusTip(tr("Connect to a server"));
            actions[0].triggered.connect(&slotOpenConnection);
            
            actions[1].setShortcut(tr("Ctrl+N"));
            actions[1].setStatusTip(tr("Create a new file"));
            //actions[1].triggered.connect(&MainWindow.slotNewFile);
            
            actions[2].setShortcut(tr("Ctrl+S"));
            actions[2].setStatusTip(tr("Save the document"));
            //actions[2].triggered.connect(&MainWindow.slotSaveFile);
            
            actions[3].setShortcut(tr("Ctrl+Q"));
            actions[3].setStatusTip(tr("Exit the application"));
            actions[3].triggered.connect(&MainWindow.close);
            
            actions[4].setShortcut(tr("Ctrl+Z"));
            actions[4].setStatusTip(tr("Undo last change"));
            //actions[4].triggered.connect(&MainWindow.slotUndo);
            
            actions[5].setShortcut(tr("Ctrl+Y"));
            actions[5].setStatusTip(tr("Redo last undone change"));
            //actions[5].triggered.connect(&MainWindow.slotRedo);
            
            actions[6].setShortcut(tr("Ctrl+X"));
            actions[6].setStatusTip(tr("Cut the current selection's contents to the clipboard"));
            //actions[6].triggered.connect(&MainWindow.slotCut);
            
            actions[7].setShortcut(tr("Ctrl+C"));
            actions[7].setStatusTip(tr("Copy the current selection's contents to the clipboard"));
            //actions[7].triggered.connect(&MainWindow.slotCopy);
            
            actions[8].setShortcut(tr("Ctrl+V"));
            actions[8].setStatusTip(tr("Paste the clipboard's contents into the current selection"));
            //actions[8].triggered.connect(&MainWindow.slotPaste);
            
            actions[9].setStatusTip(tr("About collabEdit"));
            actions[9].triggered.connect(&slotAbout);
        }
        
        void createMenus() {
            auto menu = parent.menuBar.addMenu(tr("&File"));
            
            menu.addAction(actions[0]);
            menu.addSeparator();
            menu.addAction(actions[1]);
            menu.addAction(actions[2]);
            menu.addSeparator();
            menu.addAction(actions[3]);
            
            menu = parent.menuBar.addMenu(tr("&Edit"));
            
            menu.addAction(actions[4]);
            menu.addAction(actions[5]);
            menu.addSeparator();
            menu.addAction(actions[6]);
            menu.addAction(actions[7]);
            menu.addAction(actions[8]);
            
            viewMenu = parent.menuBar.addMenu(tr("&View"));
            
            menu = parent.menuBar.addMenu(tr("&?"));
            
            menu.addAction(actions[9]);
        }
        
        void createToolBars() {
            auto bar = parent.addToolBar(tr("Connection"));
            bar.addAction(actions[0]);
            
            auto menu = new QMenu(tr("File"));
            //menu.setIcon(...);
            
            menu.addActions([new QAction(tr("D"), parent), new QAction(tr("Plain text"), parent)]);
            
            bar = parent.addToolBar(tr("File"));
            bar.addAction(menu.menuAction());
            bar.addAction(actions[2]);
        }
        
        void setupGlobal(QMainWindow parent) {
            this.parent = parent;
            resourceManager = new ResourceManager();
            
            parent.setWindowIcon(resourceManager.getIcon(ResourceManager.WINDOW_ICON));
            parent.setWindowTitle(tr("collabEdit"));
            createActions();
            
            createMenus();
            createToolBars();
            
            chat = new Chat();
            compiler = new Compiler();
            projectTree = new ProjectTree();
            tabWidget = new TabWidget();
            userList = new UserList();
            
            docks ~= new QDockWidget(tr("Project"));
            docks ~= new QDockWidget(tr("Users"));
            docks ~= new QDockWidget(tr("Compiler"));
            docks ~= new QDockWidget(tr("Chat"));
            
            docks[0].setWidget(projectTree);
            docks[1].setWidget(userList);
            docks[2].setWidget(compiler);
            docks[3].setWidget(chat);
            
            parent.statusBar.showMessage(tr("Ready"));
        }
        
        void setupPreview() {
            auto preview = new QLabel();
            preview.setAlignment(Qt.AlignCenter);
            preview.setPixmap(resourceManager.getPixmap(ResourceManager.PREVIEW));
            
            parent.setCentralWidget(preview);
        }
        
        void setupUi() {
            foreach (dock; docks)
                viewMenu.addAction(dock.toggleViewAction());
            
            parent.addDockWidget(Qt.LeftDockWidgetArea, docks[0]);
            parent.addDockWidget(Qt.LeftDockWidgetArea, docks[1]);
            parent.addDockWidget(Qt.BottomDockWidgetArea, docks[2]);
            parent.addDockWidget(Qt.BottomDockWidgetArea, docks[3]);
            
            parent.setCentralWidget(tabWidget);
        }
        
        void slotOpenConnection() {
            // open connection manager
        }
        
        void slotAbout() {
            QMessageBox.about(parent, tr("About collabEdit"), tr("Core Developers:\nLester Martin\n\nGUI Developers:\nDanny Trunk\n\nSome license stuff here..."));
        }
}

struct MainWindow {
    mixin MainWindow_UI;
    
    void slotOpenConnection() {}
    void slotNewFile() {}
    void slotSaveFile() {}
    void close() {}
    void slotAbout() {}
}

mixin QT_END_NAMESPACE;