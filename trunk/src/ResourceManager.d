module src.ResourceManager;

import qt.gui.QIcon;
import src.Resources;

class ResourceManager {
	public:
		const enum ICON {
			WINDOW_ICON = 0
		}
	
	private:
		QIcon[] icons;
	
	public:
		this() {
			icons ~= new QIcon(":icon.png");
		}
		
		QIcon getIcon(int key) {
			return icons[key];
		}
}