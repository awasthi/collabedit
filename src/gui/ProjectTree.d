module src.gui.ProjectTree;

private import src.gui.ProjectTree_UI;

class ProjectTree : QTreeView {
    public:
        this(QWidget parent = null) {
            super(parent);
            setupUi(this);
        }
    
    private:
        mixin ProjectTree_UI;
}