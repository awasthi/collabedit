module src.gui.UserList;

private import src.gui.UserList_UI;

class UserList : QListView {
    private:
        mixin UserList_UI;
    
    public:
        this(QWidget parent = null) {
            super(parent);
            setupUi(this);
        }
}