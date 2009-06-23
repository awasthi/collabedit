module src.Main;

import qt.core.QTranslator;
import qt.gui.QApplication;
import src.gui.widgets.MainWindow;

int main(char[][] args) {
	scope app = new QApplication(args);
	
	scope translator = new QTranslator();
	translator.load("de_DE", "lang");
	
	scope window = new MainWindow();
	window.show();
	
	app.installTranslator(translator);
	return app.exec();
}