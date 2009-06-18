module src.Main;

import qt.gui.QApplication;
import src.gui.widgets.MainWindow;

int main(char[][] args) {
	scope app = new QApplication(args);
	
	scope window = new MainWindow();
	window.show();
	
	return app.exec();
}