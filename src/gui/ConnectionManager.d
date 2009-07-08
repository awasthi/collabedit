module src.gui.ConnectionManager;

private import src.gui.ConnectionManager_UI;

class ConnectionManager : QDialog {
    private:
        mixin ConnectionManager_UI;
        
        void slotConnect() {
            // use connectionsView to get information about selected item to connect to it
        }
    
    public:
        this(QWidget parent = null) {
            super(parent);
            
            setWindowTitle(tr("Open connection"));
            setupUi(this);
        }
}