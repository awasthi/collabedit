/*******************************************************************************
 Author:                        Lester L. Martin II
 Copyright:                     Lester L. Martin II and CollabEdit Project
 Liscense:                      $(GPLv1)
 Release:                       Initial, June 2009
 *******************************************************************************/

module src.configuration.Configurator;

private {
    import tango.text.xml.Document;
    import tango.io.model.IConduit;
    import tango.io.vfs.model.Vfs;
    import tango.io.vfs.FileFolder;
    import TUtil = tango.text.Util;
}

/*******************************************************************************
 define an extension as char[]
 *******************************************************************************/
alias char[] Extension;

/*******************************************************************************
 define the operations on a file
 *******************************************************************************/
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

/*******************************************************************************
 describes handlers as a type
 *******************************************************************************/
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

    /*
       describes language by it's name... has a list of extensions as a string
       use something to figure out if extension (char[]) is in the string of
       language
    */
    char[][char[]]              languages;

    /*
       should be able to get a *.xml for ext and parse it into a Configuration
       should store in configuration Table
       if there's no configuration give it the NullConf value
    */
    void getConf(Extension ext) {
        foreach(Extension loc, char[] list; languages) {
            if(TUtil.containsPattern(ext, list)) parseExt(loc ~ ".xml");
        }
    }

    /*
       opens a language descriptor file
       and parses it into the configurations
    */
    void parseExt(char[] loc) {
        /* open and read file, set up document (xml) */
        auto text = pull((new FileHost(loc)).input);
        Document!(char) doc = new Document!(char);

        /* parse the document before playing with it :-) */
        doc.parse(text);

        /* parse it into the languages array */
        auto root = doc.tree;

        auto conf = new ConfigurationT;

        /* do some actual parsing :-) */
        foreach(elem; root.query["lang"]) {
            conf.name = elem.attributes.value("name").value;

            foreach(elem2; elem.query["keywordLists"]) {
                foreach(elem3; elem2.query["keywords"]) {
                    conf.keywords[elem3.attributes.value("name").value]
                        = elem3.value;
                }
            }

            foreach(elem2; elem.query["styles"]) {
                foreach(elem3; elem2.query["wordsStyle"]) {
                    conf.styles[elem3.attributes.value("name").value]
                        =   Style(
                                    elem3.attributes.value("color").value,
                                    elem3.attributes.value("style").value
                            );
                }
            }
            configurations[elem.attributes.value("name").value].conf = conf;
        }        
    }

    /*
       pulls all of the text out this input stream
       returns the text
    */
    char[] pull(InputStream stream) {
        char[] ret, temp;

        for(; stream.read(temp) != IOStream.Eof;)
            ret ~= temp;

        return ret;
    }

public:
    /* gets master descriptor of extensions file and parses it */
    this(char[] loc) {
        
        /* open and read file, set up document (xml) */
        auto text = pull((new FileHost(loc)).input);
        Document!(char) doc = new Document!(char);

        /* parse the document before playing with it :-) */
        doc.parse(text);

        /* parse it into the languages array */
        auto root = doc.tree;

        /* ok time for some actual parsing, hooray! */
        foreach(elem; root.query["extensions"]) {
            foreach(elem2; elem.query["ext"]) {
                languages[elem2.attributes.value("conf").value]
                    = elem2.attributes.value("ext").value;
            }
        }
    }

    /*
       the on open event
       synchronized so no 2 accesses at same file
       and no 2 accesses on the configurations
    */
    synchronized ConfigurationT onOpen(Extension ext) {
        Extension use;

        foreach(Extension loc, char[] list; languages) {
            if(TUtil.containsPattern(ext, list)) use = loc;
        }

        if(configurations[use].isNull)
            getConf(ext);
        configurations[use].conf.used++;
        return configurations[use].conf;
    }

    /*
       the on close event
       synchronized so the proper reading of the used
       var is done so it can actually release mem to GC
    */
    synchronized void onClose(Extension ext) {
        Extension use;

        foreach(Extension loc, char[] list; languages) {
            if(TUtil.containsPattern(ext, list)) use = loc;
        }

        if(!configurations[use].isNull) {
            configurations[use].conf.used--;

            if(configurations[use].conf.used <= 0) {
                // this should make the gc able to delete the ConfigurationT
                configurations[use].conf   = null;
                configurations[use].isNull = true;
            }
        }
    }
}