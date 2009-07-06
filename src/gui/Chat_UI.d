module src.gui.Chat_UI;

public {
    import qt.gui.QHBoxLayout;
    import qt.gui.QLineEdit;
    import qt.gui.QPushButton;
    import qt.gui.QTextEdit;
    import qt.gui.QVBoxLayout;
    import qt.gui.QWidget;
}

mixin QT_BEGIN_NAMESPACE;

template Chat_UI() {
    private:
        QTextEdit chat;
        QLineEdit input;
        
        void setupUi(QWidget parent) {
            chat = new QTextEdit();
            chat.setReadOnly(true);
            
            input = new QLineEdit();
            
            auto send = new QPushButton(tr("Send"));
            send.clicked.connect(&Chat.slotSendClicked);
            
            auto hLayout = new QHBoxLayout();
            hLayout.setMargin(0);
            hLayout.addWidget(input);
            hLayout.addWidget(send);
            
            auto subWidget = new QWidget();
            subWidget.setLayout(hLayout);
            
            auto vLayout = new QVBoxLayout();
            vLayout.setMargin(0);
            vLayout.addWidget(chat);
            vLayout.addWidget(subWidget);
            
            parent.setLayout(vLayout);
        }
        
        char[] getInput() {
            return input.text();
        }
        
        void appendToChat(char[] date, char[] from, char[] message) {
            chat.append(date ~ " " ~ from ~ ": " ~ message);
        }
}

struct Chat {
    mixin Chat_UI;
    void slotSendClicked() {}
}

mixin QT_END_NAMESPACE;