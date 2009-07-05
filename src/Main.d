module src.Main;

//import qt.core.QTranslator; // not ported yet
import qt.gui.QApplication;
import src.gui.MainWindow;

int main(char[][] args) {
    scope app = new QApplication(args);
    
    /*scope translator = new QTranslator();
    translator.load("de_DE", "lang");
    app.installTranslator(translator);*/
    
    scope window = new MainWindow();
    window.show();
    
    return app.exec();
}