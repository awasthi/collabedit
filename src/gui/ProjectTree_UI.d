module src.gui.ProjectTree_UI;

public {
    import qt.gui.QTreeView;
    import qt.gui.QWidget;
}

mixin QT_BEGIN_NAMESPACE;

template ProjectTree_UI() {
    private void setupUi(QTreeView parent) {
    }
}

struct ProjectTree {
    mixin ProjectTree_UI;
}

mixin QT_END_NAMESPACE;