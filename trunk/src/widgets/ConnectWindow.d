module src.widgets.ConnectWindow;

import qt.core.QDir;
import qt.gui.QDialog;
import qt.gui.QDialogButtonBox;
import qt.gui.QFormLayout;
import qt.gui.QHBoxLayout;
import qt.gui.QLabel;
import qt.gui.QLineEdit;
import qt.gui.QPushButton;
import qt.gui.QSpinBox;
import qt.gui.QStyle;
import qt.gui.QVBoxLayout;
import qt.gui.QWidget;

class ConnectWindow : QDialog {
	private:
		QLineEdit host, name, password, file;
		QPushButton fileSubmit;
	
	public:
		this(QWidget parent) {
			super(parent);
			
			//setWindowIcon(new QIcon(":icon.png"));
			setWindowTitle("Open Connection");
			
			host = new QLineEdit();
			host.setInputMask("000.000.000.000:00000");
			host.setText("127.0.0.1:49152");
			
			name = new QLineEdit();
			name.setText(QDir.home.dirName());
			
			password = new QLineEdit();
			password.setEchoMode(QLineEdit_EchoMode.Password);
			
			file = new QLineEdit();
			file.setText(QDir.currentPath() ~ "/sessions/" ~ host.text() ~ ".cedit");
			
			fileSubmit = new QPushButton(style.standardIcon(QStyle.SP_DirOpenIcon), "Browse...");
			
			auto sessionFileLayout = new QHBoxLayout();
			sessionFileLayout.addWidget(file);
			sessionFileLayout.addWidget(fileSubmit);
			
			auto sessionFile = new QWidget();
			sessionFile.setLayout(sessionFileLayout);
			
			auto layout = new QFormLayout();
			layout.addRow(new QLabel("Host:"), host);
			layout.addRow(new QLabel("Name:"), name);
			layout.addRow(new QLabel("Password:"), password);
			//layout.addRow(new QLabel("Session file:"), sessionFile);
			
			auto buttonBox = new QDialogButtonBox(QDialogButtonBox.Cancel | QDialogButtonBox.Ok);
			
			auto container = new QWidget();
			container.setLayout(layout);
			
			auto mainLayout = new QVBoxLayout();
			mainLayout.addWidget(container);
			mainLayout.addWidget(buttonBox);
			setLayout(mainLayout);
		}
}