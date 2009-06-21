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
    debug(Configurator) {
        import tango.io.Stdout;
    }
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
    ConfigurationT  conf;
    bool    isNull = true;
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
        parseExt(languages[ext] ~ ".xml");
    }

    /*
       opens a language descriptor file
       and parses it into the configurations
    */
    void parseExt(char[] loc) {
        /* open and read file, set up document (xml) */
        auto text = pull(new FileHost(loc));

        Document!(char) doc = new Document!(char);

        /* parse the document before playing with it :-) */
        doc.parse(text);

        /* parse it into the languages array */
        auto root = doc.tree;

        // some temps
        char[] name, color, style;
        ConfigurationT conf;


        /* do some actual parsing :-) */
        foreach(elem; root.query.descendant("lang")) {
            conf = new ConfigurationT;
            
            foreach(elem2; elem.query.attribute("name")) {
                conf.name = elem2.value.dup;

                debug(Configurator) {
                    Stdout(conf.name).newline.flush;
                }
            }

            foreach(elem2; elem.query.descendant("keywordLists")) {
                foreach(elem3; elem2.query.descendant("keywords")) {
                    foreach(elem4; elem3.query.attribute("name")) {
                        name = elem4.value;
                    }

                    conf.keywords[name.dup] = elem3.value.dup;

                    debug(Configurator) {
                        Stdout(conf.keywords[name]).newline.flush;
                    }
                }
            }

            foreach(elem2; elem.query.descendant("styles")) {
                foreach(elem3; elem2.query.descendant("wordsStyle")) {
                    foreach(elem4; elem3.query.attribute("name")) {
                        name = elem4.value;
                    }

                    foreach(elem4; elem3.query.attribute("color")) {
                        color = elem4.value;
                    }

                    foreach(elem4; elem3.query.attribute("style")) {
                        style = elem4.value;
                    }

                    conf.styles[name.dup] = Style(color.dup, style.dup);
                }

                debug(Configurator) {
                    Stdout(name)("/n")(color)("/n")(style).newline.flush;
                }
            }

            configurations[conf.name.dup] = Configuration(conf);
        }        
    }

    /*
       pulls all of the text out this input stream
       returns the text
    */
    char[] pull(FileHost loc) {
        char[] ret, temp;
        size_t loca;

        auto inp = loc.input;

        ret = cast(char[])inp.load();

        inp.close;

        return ret;
    }

public:
    /* gets master descriptor of extensions file and parses it */
    this(char[] loc) {

        /* open and read file, set up document (xml) */
        auto text = pull(new FileHost(loc));
        Document!(char) doc = new Document!(char);

        /* parse the document before playing with it :-) */
        doc.parse(text);

        /* temp vars */
        char[] lang, exts;

        /* parse it into the languages array */
        foreach(elem; doc.query.descendant) {
            foreach(elem2; elem.query.descendant("ext")) {
                foreach(elem3; elem2.query.attribute("conf")) {
                    lang = elem3.value;

                    debug(Configurator) {
                        Stdout(elem3.value).newline.flush;
                    }
                }

                foreach(elem3; elem2.query.attribute("ext")) {
                    exts = elem3.value;

                    debug(Configurator) {
                        Stdout(elem3.value).newline.flush;
                    }
                }

                foreach(temp; TUtil.split(exts, ","))
                    languages[temp.dup] = lang.dup;
            }
        }
    }

    /*
       the on open event
       synchronized so no 2 accesses at same file
       and no 2 accesses on the configurations
    */
    synchronized ConfigurationT onOpen(Extension ext) {
        try {
            configurations[languages[ext]].conf.used++;
        } catch {
            getConf(ext);
            //configurations[languages[ext]].conf.used++;
        }
        return configurations[languages[ext]].conf;
    }

    /*
       the on close event
       synchronized so the proper reading of the used
       var is done so it can actually release mem to GC
    */
    synchronized void onClose(Extension ext) {
        configurations[languages[ext]].conf.used--;

        if(configurations[languages[ext]].conf.used <= 0) {
            delete configurations[languages[ext]].conf;
        }
    }
}

debug(Configurator) {
    void main() {
        auto man = new ConfigurationManager("extensions.xml");
        auto conf = man.onOpen("d");
        man.onClose("d");
        Stdout("no problems yet?").newline.flush;
    }
}