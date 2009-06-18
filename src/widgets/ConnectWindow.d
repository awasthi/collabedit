module src.widgets.ConnectWindow;

import qt.gui.QDialog;
import qt.gui.QDialogButtonBox;
import qt.gui.QFormLayout;
import qt.gui.QHBoxLayout;
import qt.gui.QLabel;
import qt.gui.QLineEdit;
import qt.gui.QPushButton;
import qt.gui.QSpinBox;
import qt.gui.QVBoxLayout;
import qt.gui.QWidget;

class ConnectWindow : QDialog {
	private:
		QLineEdit ip, name, password;
		QPushButton color;
		QSpinBox port;
		QWidget host;
	
	public:
		this(QWidget parent) {
			super(parent);
			
			//setWindowIcon(new QIcon(":icon.png"));
			setWindowTitle("Open Connection");
			
			ip = new QLineEdit();
			port = new QSpinBox();
			
			auto hostLayout = new QHBoxLayout();
			hostLayout.addWidget(ip);
			hostLayout.addWidget(port);
			
			host = new QWidget();
			host.setLayout(hostLayout);
			
			color = new QPushButton();
			
			name = new QLineEdit();
			
			password = new QLineEdit();
			password.setEchoMode(QLineEdit_EchoMode.Password);
			
			auto layout = new QFormLayout();
			layout.addRow(new QLabel("Host:"), host);
			layout.addRow(new QLabel("Color:"), color);
			layout.addRow(new QLabel("Name:"), name);
			layout.addRow(new QLabel("Password:"), password);
			//layout.addRow(new QLabel("Session file:"), null);
			
			auto buttonBox = new QDialogButtonBox(QDialogButtonBox.Cancel | QDialogButtonBox.Ok);
			
			auto container = new QWidget();
			container.setLayout(layout);
			
			auto mainLayout = new QVBoxLayout();
			mainLayout.addWidget(container);
			mainLayout.addWidget(buttonBox);
			setLayout(mainLayout);
		}
}