module src.gui.UserList;

private import src.gui.UserList_UI;

class UserList : QListView {
    public:
        this(QWidget parent = null) {
            super(parent);
            setupUi(this);
        }
    
    private:
        mixin UserList_UI;
}