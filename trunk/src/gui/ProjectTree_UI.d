module src.gui.ProjectTree_UI;

public {
    import qt.gui.QItemSelectionModel;
    import qt.gui.QTreeView;
    import qt.gui.QWidget;
    //import src.gui.ProjectTree_Model;
}

mixin QT_BEGIN_NAMESPACE;

template ProjectTree_UI() {
    private void setupUi(QTreeView parent) {
        /*scope data = new ProjectTree_Model();
        scope selections = new QItemSelectionModel(data);
        
        parent.setModel(data);
        parent.setSelectionModel(selections);*/
        parent.setUniformRowHeights(true);
        parent.viewport.setAttribute(Qt.WA_StaticContents);
        parent.setAttribute(Qt.WA_MacShowFocusRect, false);
    }
}

struct ProjectTree {
    mixin ProjectTree_UI;
}

mixin QT_END_NAMESPACE;