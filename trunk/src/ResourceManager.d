module src.ResourceManager;

import qt.gui.QIcon;
import qt.gui.QPixmap;
import qt.gui.QStyle;
import src.Resources;

class ResourceManager {
	public:
		enum {
			WINDOW_ICON,
			PREVIEW,
			FILE,
			FLOPPY,
			CUT,
			COPY,
			PASTE,
			ARROW_RIGHT
		}
	
	private:
		Object[] obj;
	
	public:
		this(QStyle style) {
			obj ~= new QIcon(":icon");
			obj ~= new QPixmap(":preview");
			obj ~= style.standardIcon(QStyle.SP_FileIcon);
			obj ~= style.standardIcon(QStyle.SP_DriveFDIcon);
			obj ~= null;
			obj ~= null;
			obj ~= null;
			obj ~= style.standardIcon(QStyle.SP_ArrowRight);
		}
		
		QIcon getIcon(int key) {
			return cast(QIcon) obj[key];
		}
		
		QPixmap getPixmap(int key) {
			return cast(QPixmap) obj[key];
		}
}