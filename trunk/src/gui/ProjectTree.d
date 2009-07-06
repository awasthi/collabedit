module src.gui.ProjectTree;

private import src.gui.ProjectTree_UI;

class ProjectTree : QTreeView {
    private:
        mixin ProjectTree_UI;
    
    public:
        this(QWidget parent = null) {
            super(parent);
            setupUi(this);
        }
}