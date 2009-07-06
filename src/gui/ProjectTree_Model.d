module src.gui.ProjectTree_Model;

private {
    import qt.core.QAbstractItemModel;
    import qt.gui.QFileIconProvider;
}

class ProjectTree_Model : QAbstractItemModel {
    private:
        QFileIconProvider iconProvider;
        char[][] lastEntryList;
        QDir lastDirectory;
        
        char[][] entryList(QDir dir) {
            if (dir == lastDirectory)
                return lastEntryList;
            
            lastEntryList = dir.entryList(entryListFlags);
            lastDirectory = dir;
            
            return lastEntryList;
        }
        
        QDir dir(Object value) {
            return value !is null ? cast(QDir) value : QDir.root();
        }
    
    public:
        static QIcon FOLDER, FILE;
        
        this(QObject parent = null)
        {
            super(parent);
            
            iconProvider = new QFileIconProvider;
            FOLDER = iconProvider.icon(QFileIconProvider.Folder);
            FILE = iconProvider.icon(QFileIconProvider.File);
        }
        
        int childCount(Object parent) {
            return entryList(dir(parent)).length;
        }
        
        Object child(Object parent, int row) {
            QDir d = dir(parent);
            return new QDir(d.absoluteFilePath(entryList(d).get(row)));
        }
        
        char[] text(Object value) {
            return (cast(QDir) value).dirName();
        }
}