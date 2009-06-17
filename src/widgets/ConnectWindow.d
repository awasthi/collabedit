module src.widgets.ConnectWindow;

import qt.gui.QDialog;

class ConnectWindow : QDialog {
	public:
		this(QWidget parent) {
			super(parent);
			
			setWindowTitle("Connect");
		}
}