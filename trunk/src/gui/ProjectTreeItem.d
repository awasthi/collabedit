module src.gui.ProjectTreeItem;

private {
    import qt.core.QVariant;
    import tango.text.Util : locatePattern;
}

class ProjectTreeItem {
    private:
        ProjectTreeItem[] childItems;
        QVariant[] itemData;
        ProjectTreeItem parentItem;
    
    public:
        this(QVariant[] data, ProjectTreeItem parent) {
            parentItem = parent;
            itemData = data;
        }
        
        void appendChild(ProjectTreeItem item) {
            childItems ~= item;
        }
        
        ProjectTreeItem child(int row) {
            return childItems[row];
        }
        
        int childCount() {
            return childItems.length;
        }
        
        QVariant data(int column) {
            return itemData[column];
        }
        
        ProjectTreeItem parent() {
            return parentItem;
        }
        
        int row() {
            if (parentItem)
                return locatePattern(parentItem.childItems, this);
            
            return 0;
        }
}