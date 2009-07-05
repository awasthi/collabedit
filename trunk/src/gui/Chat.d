module src.gui.Chat;

private import src.gui.Chat_UI;

class Chat : QWidget {
    public:
        this(QWidget parent = null) {
            super(parent);
            setupUi(this);
        }
    
    private:
        mixin Chat_UI;
        
        void slotSendClicked() {
            // input.text()
        }
}