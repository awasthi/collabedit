module src.gui.MainWindow;

private import src.gui.MainWindow_UI;

class MainWindow : QMainWindow {
    public:
        this(QWidget parent = null) {
            super(parent);
            
            setupPreview(this);
        }
    
    private:
        mixin MainWindow_UI;
}