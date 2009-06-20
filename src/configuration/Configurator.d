/*******************************************************************************
 Author:                        Lester L. Martin II
 Copyright:                     Lester L. Martin II and CollabEdit Project
 Liscense:                      $(GPL)
 Release:                       Initial, June 2009
 *******************************************************************************/

module Configurator;

private {
    import tango.text.xml.Document;
    import tango.io.model.IConduit;
    import tango.io.vfs.model.Vfs;
    import tango.io.vfs.FileFolder;
    import TUtil = tango.text.Util;
}

/// define an extension as char[]
typedef char[] Extension;

/// define the operations on a file
enum Operations {
    Open,
    Close 
}

/*******************************************************************************
 Describes an entire style

 Members:
    color; the color of this style

    style; I don't understand this part as of yet? Might have
        something to do with fonts?
 *******************************************************************************/
public struct Style {
    char[] color;
    char[] style;
}

/*******************************************************************************
 Describes the Configuration for a certain extension

 Members:
    name; name of the language
        ex: D, C++, not cpp,cc,d,di and stuff

    keywords; a set of keywords split into groups by name
        ex: keywords["delimiters"] should return a char[] containing
            "\" \''" for d.xml

    styles: a set of styles split into groups by name
        ex: styles["default"] should return a style

    used: how many times is this configuration used, if not at all
        wtf is it still doing around? Change to the bool part
        of the union Configuration
 *******************************************************************************/
public class ConfigurationT {
public:
    char[]          name;
    char[][char[]]  keywords;
    Style[char[]]   styles;
    ulong           used;
}

public union Configuration {
    bool    isNull = true;
    ConfigurationT  conf;
}

/// describes handlers as a type
typedef ConfigurationT delegate(Extension ext)   OpenHandler;
typedef void delegate(Extension ext)           CloseHandler;

/*******************************************************************************
 Describes the configuration of the entire editor.
 Every time a file is opened, this is asked for it's corresponding syntax
 highlight configuration.

 Has events:
    onClose(Extension ext) to be called when closing a file with the files
        extension
    onOpen(Extension ext) to be called when opening a file with the files
        extension, returns the configuration

 Usage:
    auto conf = new ConfigurationManager("extensionDescriptors.xml");
    // your class then does something like this if
    this.register(&(conf.onOpen), Operations.Open);
    this.register(&(conf.onClose), Operations.Close);

    // that sets your class to call it whenever it opens and whenever
    // it closes a file

Extra Information:
    The configuration manager only has the neccessary syntax/style
    descriptor files open only when a file using the extension is
    being used. If not, the tables for the Configuration and the file
    are closed to reduce program memory
 *******************************************************************************/
public class ConfigurationManager {
private:
    Configuration[Extension]    configurations = null;
    // describes language by it's name... has a list of extensions as a string
    // use something to figure out if extension (char[]) is in the string of
    // language
    char[][char[]]              languages;

    // should be able to get a *.xml for ext and parse it into a Configuration
    // should store in configuration Table
    // if there's no configuration give it the NullConf value
    void getConf(Extension ext) {

    }

public:
    // gets master descriptor of extensions file and parses it
    this(char[] loc) {
    }

    ConfigurationT onOpen(Extension ext) {
        if(configurations[ext].isNull)
            getConf(ext);
        configurations[ext].conf.used++;
        return configurations[ext].conf;
    }

    void onClose(Extension ext) {
        if(!configurations[ext].isNull) {
            configurations[ext].conf.used--;

            if(configurations[ext].conf.used <= 0)
                // this should make the gc able to delete the ConfigurationT
                configurations[ext].conf   = null;
                configurations[ext].isNull = true; 
        }
    }
}