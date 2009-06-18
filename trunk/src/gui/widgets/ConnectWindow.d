module src.gui.widgets.ConnectWindow;

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
import src.ResourceManager;
import src.gui.widgets.MainWindow;

class ConnectWindow : QDialog {
	public:
		this(MainWindow parent) {
			super(parent);
			
			setWindowIcon(parent.resourceManager.getIcon(ResourceManager.WINDOW_ICON));
			setWindowTitle("Open Connection");
			
			parent.host = new QLineEdit();
			parent.host.setInputMask("000.000.000.000:00000");
			parent.host.setText("127.0.0.1:49152");
			
			parent.name = new QLineEdit();
			parent.name.setText(QDir.home.dirName());
			
			parent.password = new QLineEdit();
			parent.password.setEchoMode(QLineEdit_EchoMode.Password);
			
			parent.file = new QLineEdit();
			parent.file.setText(QDir.currentPath() ~ "/sessions/" ~ parent.host.text() ~ ".cedit");
			
			auto fileSubmit = new QPushButton(style.standardIcon(QStyle.SP_DirOpenIcon), "Browse...");
			
			auto sessionFileLayout = new QHBoxLayout();
			sessionFileLayout.addWidget(parent.file);
			sessionFileLayout.addWidget(fileSubmit);
			
			auto sessionFile = new QWidget();
			sessionFile.setLayout(sessionFileLayout);
			
			auto layout = new QFormLayout();
			layout.addRow(new QLabel("Host:"), parent.host);
			layout.addRow(new QLabel("Name:"), parent.name);
			layout.addRow(new QLabel("Password:"), parent.password);
			//layout.addRow(new QLabel("Session file:"), sessionFile);
			
			auto buttonBox = new QDialogButtonBox(QDialogButtonBox.Cancel | QDialogButtonBox.Ok);
			buttonBox.accepted.connect(&parent.acceptConnection);
			buttonBox.rejected.connect(&parent.rejectConnection);
			
			auto container = new QWidget();
			container.setLayout(layout);
			
			auto mainLayout = new QVBoxLayout();
			mainLayout.addWidget(container);
			mainLayout.addWidget(buttonBox);
			setLayout(mainLayout);
		}
}