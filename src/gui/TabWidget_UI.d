module src.gui.TabWidget_UI;

public {
    import qt.gui.QTabWidget;
    import qt.gui.QWidget;
}

mixin QT_BEGIN_NAMESPACE;

template TabWidget_UI() {
    public void setupUi(QTabWidget parent) {
        parent.setTabsClosable(true);
        parent.setMovable(true);
    }
}

struct TabWidget {
    mixin TabWidget_UI;
}

mixin QT_END_NAMESPACE;