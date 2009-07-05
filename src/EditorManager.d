module src.EditorManager;

import src.Configurator;
import src.gui.CodeEditor;

class EditorManager {
    private:
        CodeEditor[char[]] editors = null;
        ConfigurationManager confMan;

    public:
        this() {
            /* Init Configuration manager */
            confMan = new ConfigurationManager("syntax/extensions.xml");

            /* Create plain text editor */
            editors["plaintext"] = new CodeEditor(null);
        }

        void setText(char[] ext, char[] text) {
            get(ext).setPlainText(text);
        }

        CodeEditor get(char[] ext) {
            try {
                if(editors[confMan.getConfiguration(ext).name] is null)
                    editors[confMan.getConfiguration(ext).name] = new CodeEditor(confMan.onOpen(ext));
            }
            catch {
                editors[confMan.getConfiguration(ext).name] = new CodeEditor(confMan.onOpen(ext));
            }
            return editors[confMan.getConfiguration(ext).name];
        }
}