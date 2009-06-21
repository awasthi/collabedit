module src.gui.widgets.Chat;

import qt.gui.QHBoxLayout;
import qt.gui.QLineEdit;
import qt.gui.QPushButton;
import qt.gui.QStyle;
import qt.gui.QTextEdit;
import qt.gui.QVBoxLayout;
import qt.gui.QWidget;

class Chat : QWidget {
	private:
		QTextEdit chat;
		QLineEdit input;
	
	public:
		this() {
			super();
			
			chat = new QTextEdit();
			chat.setReadOnly(true);
			
			input = new QLineEdit();
		
			auto submit = new QPushButton("Send");
			submit.clicked.connect(&submitClicked);
			
			auto hLayout = new QHBoxLayout();
			hLayout.addWidget(input);
			hLayout.addWidget(submit);
			
			auto subWidget = new QWidget();
			subWidget.setLayout(hLayout);
			
			auto vLayout = new QVBoxLayout();
			vLayout.addWidget(chat);
			vLayout.addWidget(subWidget);
			
			setLayout(vLayout);
		}
		
	private:
		void submitClicked() {
			char[] text = input.text();
		}
}