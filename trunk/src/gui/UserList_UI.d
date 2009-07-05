module src.gui.UserList_UI;

public {
    import qt.gui.QListView;
    import qt.gui.QWidget;
}

mixin QT_BEGIN_NAMESPACE;

template UserList_UI() {
    public void setupUi(QListView parent) {
    }
}

struct UserList {
    mixin UserList_UI;
}

mixin QT_END_NAMESPACE;