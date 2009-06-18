module src.ResourceManager;

import qt.gui.QIcon;
import qt.gui.QPixmap;
import src.Resources;

class ResourceManager {
	public:
		enum {
			WINDOW_ICON,
			PREVIEW
		}
	
	private:
		Object[] obj;
	
	public:
		this() {
			obj ~= new QIcon(":icon");
			obj ~= new QPixmap(":preview");
		}
		
		QIcon getIcon(int key) {
			return cast(QIcon) obj[key];
		}
		
		QPixmap getPixmap(int key) {
			return cast(QPixmap) obj[key];
		}
}