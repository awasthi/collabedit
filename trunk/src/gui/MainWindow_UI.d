module src.gui.MainWindow_UI;

public {
    import qt.gui.QDockWidget;
    import qt.gui.QMainWindow;
    import src.gui.Chat;
    import src.gui.Compiler;
    import src.gui.ProjectTree;
    import src.gui.TabWidget;
    import src.gui.UserList;
}

mixin QT_BEGIN_NAMESPACE;

template MainWindow_UI() {
    public:
        Chat chat;
        Compiler compiler;
        ProjectTree projectTree;
        TabWidget tabWidget;
        UserList userList;
        
        QDockWidget[] docks;
        
        void setupUi(QMainWindow parent) {
            parent.setWindowTitle(tr("collabEdit"));
            
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
            
            parent.addDockWidget(Qt.LeftDockWidgetArea, docks[0]);
            parent.addDockWidget(Qt.LeftDockWidgetArea, docks[1]);
            parent.addDockWidget(Qt.BottomDockWidgetArea, docks[2]);
            parent.addDockWidget(Qt.BottomDockWidgetArea, docks[3]);
            
            parent.setCentralWidget(tabWidget);
        }
}

struct MainWindow {
    mixin MainWindow_UI;
}

mixin QT_END_NAMESPACE;