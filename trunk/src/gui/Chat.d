module src.gui.Chat;

private {
    import src.gui.Chat_UI;
    import tango.time.Clock;
    import tango.text.locale.Locale;
}

class Chat : QWidget {
    private:
        mixin Chat_UI;
        
        void slotSendClicked() {
            // appendToChat(layout("{:HH:mm}", Clock.now()), "user", getInput())
        }
    public:
        this(QWidget parent = null) {
            super(parent);
            setupUi(this);
        }
}