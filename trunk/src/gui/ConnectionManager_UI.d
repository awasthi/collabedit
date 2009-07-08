module src.gui.ConnectionManager_UI;

public {
    import qt.gui.QDialog;
    import qt.gui.QDialogButtonBox;
    import qt.gui.QHBoxLayout;
    import qt.gui.QListView;
}

mixin QT_BEGIN_NAMESPACE;

template ConnectionManager_UI() {
    private:
        QListView connectionsView;
        
        void setupUi(QDialog parent) {
            connectionsView = new QListView();
            
            auto buttonBox = new QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Close, Qt.Vertical);
            buttonBox.accepted.connect(&ConnectionManager.slotConnect);
            buttonBox.rejected.connect(&ConnectionManager.close);
            
            auto layout = new QHBoxLayout(parent);
            layout.addWidget(connectionsView);
            layout.addWidget(buttonBox);
        }
}

struct ConnectionManager {
    mixin ConnectionManager_UI;
    void slotConnect() {}
    void close() {}
}

mixin QT_END_NAMESPACE;