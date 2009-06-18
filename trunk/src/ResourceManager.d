module src.ResourceManager;

import qt.gui.QIcon;
import qt.gui.QPixmap;
import src.Resources;

class ResourceManager {
	public:
		const enum {
			WINDOW_ICON = 0,
			PREVIEW = 1
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