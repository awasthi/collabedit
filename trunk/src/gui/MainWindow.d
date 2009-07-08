module src.gui.MainWindow;

private import src.gui.MainWindow_UI;

class MainWindow : QMainWindow {
    private:
        mixin MainWindow_UI;
    
    public:
        this(QWidget parent = null) {
            super(parent);
            
            setupGlobal(this);
            setupPreview();
            setupUi();
        }
}