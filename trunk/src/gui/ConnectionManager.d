module src.gui.ConnectionManager;

private {
    import src.gui.ConnectionManager_UI;
    import src.gui.MainWindow;
}

class ConnectionManager : QDialog {
    private:
        mixin ConnectionManager_UI;
        
        void slotConnect() {
            // use connectionsView to get information about selected item to connect to it
            close();
            
            (cast(MainWindow) parent).setupUi();
        }
    
    public:
        this(QWidget parent) {
            super(parent);
            
            setWindowTitle(tr("Open connection"));
            setupUi(this);
        }
}