module src.gui.MainWindow;

private {
    import qt.gui.QMessageBox;
    import src.gui.MainWindow_UI;
}

class MainWindow : QMainWindow {
    public:
        this(QWidget parent = null) {
            super(parent);
            setupPreview(this);
        }
    
    private:
        mixin MainWindow_UI;
        
        void slotOpenConnection() {
            // open connection manager
        }
        
        void slotNewFile() {
        }
        
        void slotSaveFile() {
        }
        
        void slotAbout() {
            QMessageBox.about(this, tr("About collabEdit"), tr("Core Developers:\nLester Martin\n\nGUI Developers:\nDanny Trunk\n\nSome license stuff here..."));
        }
}