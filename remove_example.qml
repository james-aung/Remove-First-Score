 import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2 // FileDialogs
import QtQuick.Window 2.3
import Qt.labs.folderlistmodel 2.2
import Qt.labs.settings 1.0
import QtQml 2.8
import MuseScore 3.0
import FileIO 3.0

MuseScore {
    menuPath: "Plugins." + qsTr("Remove Example")
    version: "1.0"
    requiresScore: false
    description: qsTr("Removes first example")
    pluginType: "dialog"
    
    Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            removeExample.title = qsTr("Remove Example") ;
            removeExample.thumbnailName = "batch_convert_thumbnail.png";
            removeExample.categoryCode = "batch-processing";
        }
    }

    MessageDialog {
        id: versionError
        visible: false
        title: qsTr("Unsupported MuseScore Version")
        text: qsTr("This plugin needs MuseScore 3 or later")
        onAccepted: {
            removeExample.parent.Window.window.close();
        }
    }

    Settings {
        id: mscorePathsSettings
        category: "application/paths"
        property var myScores
    }

    onRun: {
        // check MuseScore version
        if (mscoreMajorVersion < 3) { // we should really never get here, but fail at the imports above already
            removeExample.visible = false
            versionError.open()
        }
        else
            removeExample.visible = true // needed for unknown reasons
        if (settings.iPath==="")
            settings.iPath=mscorePathsSettings.myScores;
        if (settings.ePath==="")
            settings.ePath=settings.iPath;
        
        var lastoption = importWhat.buttons[settings.importWhat];
        if (lastoption) lastoption.checked=true;
    }

    id: removeExample

    // `width` and `height` allegedly are not valid property names, works regardless and seems needed?!
    width: mainRow.childrenRect.width + mainRow.anchors.margins*2
    height: mainRow.childrenRect.height + mainRow.anchors.margins*2


    // Mutally exclusive in/out formats, doesn't work properly
    ButtonGroup  { id: mscz }
    ButtonGroup  { id: mscx }
    ButtonGroup  { id: xml }
    ButtonGroup  { id: mxl }
    ButtonGroup  { id: musicxml }
    ButtonGroup  { id: mid }
    ButtonGroup  { id: midi }
    ButtonGroup  { id: pdf }

    GridLayout {
        id: mainRow
        columnSpacing: 2
        columns: 3
        anchors.margins: 10

        GroupBox {
            id: inFormats
            title: " " + qsTr("Input Formats") + " "
            Layout.margins: 10
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.column: 0
            Layout.row: 1
            Layout.rowSpan: 1
            property var extensions: new Array
            Grid {
                spacing: 0
                columns: 2
                flow: Flow.TopToBottom
                enabled: true
                SmallCheckBox {
                    id: inMscz
                    text: "*.mscz"
                    checked: true
                    //ButtonGroup.group: mscz
                    onClicked: {
                        if (checked && outMscz.checked)
                            outMscz.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "MuseScore files")
                     : qsTranslate("Ms::MuseScore", "MuseScore Files")
                }
                SmallCheckBox {
                    id: inMscx
                    text: "*.mscx"
                    //ButtonGroup.group: mscx
                    onClicked: {
                        if (checked && outMscx.checked)
                            outMscx.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Uncompressed MuseScore folders (experimental)")
                     : qsTranslate("Ms::MuseScore", "MuseScore Files")
                }
                SmallCheckBox {
                    id: inMsc
                    text: "*.msc"
                    visible: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("Ms::MuseScore", "MuseScore Files")
                }
                SmallCheckBox {
                    id: inXml
                    text: "*.xml"
                    //ButtonGroup.group: xml
                    onClicked: {
                        if (checked && outXml.checked)
                            outXml.checked = !checked
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "Uncompressed MusicXML files")
                     : qsTranslate("Ms::MuseScore", "MusicXML Files")
                }
                SmallCheckBox {
                    id: inMusicXml
                    text: "*.musicxml"
                    //ButtonGroup.group: musicxml
                    visible: (mscoreMajorVersion >= 3 || (mscoreMajorVersion == 2 && mscoreMinorVersion > 1)) ? true : false // MuseScore > 2.1
                    onClicked: {
                        if (checked && outMusicXml.checked) 
                            outMusicXml.checked = !checked
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "Uncompressed MusicXML files")
                     : qsTranslate("Ms::MuseScore", "MusicXML Files")
                }
                SmallCheckBox {
                    id: inMxl
                    text: "*.mxl"
                    //ButtonGroup.group: mxl
                    onClicked: {
                        if (checked && outMxl.checked)
                            outMxl.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "Compressed MusicXML files")
                     : qsTranslate("Ms::MuseScore", "MusicXML Files")
                }
                SmallCheckBox {
                    id: inMid
                    text: "*.mid"
                    //ButtonGroup.group: mid
                    onClicked: {
                        if (checked && outMid.checked)
                            outMid.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "MIDI files")
                     : qsTranslate("Ms::MuseScore", "MIDI Files")
                }
                SmallCheckBox {
                    id: inMidi
                    text: "*.midi"
                    //ButtonGroup.group: midi
                    onClicked: {
                        if (checked && outMidi.checked)
                            outMidi.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "MIDI files")
                     : qsTranslate("Ms::MuseScore", "MIDI Files")
                }
                SmallCheckBox {
                    id: inKar
                    text: "*.kar"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "MIDI files")
                     : qsTranslate("Ms::MuseScore", "MIDI Files")
                }
                SmallCheckBox {
                    id: inMd
                    text: "*.md"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "MuseData files")
                     : qsTranslate("Ms::MuseScore", "MuseData Files")
                }
                SmallCheckBox {
                    id: inPdf
                    text: "*.pdf"
                    visible: false // needs OMR, MuseScore > 2.0 or > 3.5 and < 4?
                    //ButtonGroup.group: pdf
                    onClicked: {
                        if (checked && outPdf.checked)
                            outPdf.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("Ms::MuseScore", "Optical Music Recognition")
                }
                SmallCheckBox {
                    id: inCap
                    text: "*.cap"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Capella files")
                     : qsTranslate("Ms::MuseScore", "Capella Files")
                }
                SmallCheckBox {
                    id: inCapx
                    text: "*.capx"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Capella files")
                     : qsTranslate("Ms::MuseScore", "Capella Files")
                }
                SmallCheckBox {
                    id: inMgu
                    text: "*.mgu"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "BB files (experimental)")
                     : qsTranslate("Ms::MuseScore", "BB Files (experimental)")
                }
                SmallCheckBox {
                    id: inSgu
                    text: "*.sgu"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "BB files (experimental)")
                     : qsTranslate("Ms::MuseScore", "BB Files (experimental)")
                }
                SmallCheckBox {
                    id: inOve
                    text: "*.ove"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Overture / Score Writer files (experimental)")
                     : qsTranslate("Ms::MuseScore", "Overture / Score Writer Files (experimental)")
                }
                SmallCheckBox {
                    id: inScw
                    text: "*.scw"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Overture / Score Writer files (experimental)")
                     : qsTranslate("Ms::MuseScore", "Overture / Score Writer Files (experimental)")
                }
                SmallCheckBox {
                    id: inBmw
                    visible: ((mscoreMajorVersion > 3) || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5
                    text: "*.bmw"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Bagpipe Music Writer files (experimental)")
                     : qsTranslate("Ms::MuseScore", "Bagpipe Music Writer Files (experimental)")
                }
                SmallCheckBox {
                    id: inBww
                    text: "*.bww"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("Ms::MuseScore", "Bagpipe Music Writer files (experimental)")
                     : qsTranslate("Ms::MuseScore", "Bagpipe Music Writer Files (experimental)")
                }
                SmallCheckBox {
                    id: inGtp
                    text: "*.gtp"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                     : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGp3
                    text: "*.gp3"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                     : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGp4
                    text: "*.gp4"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                     : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGp5
                    text: "*.gp5"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                     : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGpx
                    text: "*.gpx"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                     : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGp
                    visible: ((mscoreMajorVersion > 3) || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5
                    text: "*.gp"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                     : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inPtb
                    visible: (mscoreMajorVersion > 3) ? true : false // MuseScore 3
                    text: "*.ptb"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Power Tab Editor files (experimental)")
                     : qsTranslate("Ms::MuseScore", "Power Tab Editor Files (experimental)")
                }
                SmallCheckBox {
                    id: inMsczComma // or inMsczBackup?
                    visible: ((mscoreMajorVersion > 3) || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5 and later
                    text: mscoreMajorVersion > 3 ? "*.mscz~" : "*.mscz,"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "MuseScore backup files")
                     : qsTranslate("Ms::MuseScore", "MuseScore Backup Files")
                }
                SmallCheckBox {
                    id: inMscxComma
                    visible: (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5) ? true : false // MuseScore 3.5 and 3.6 only
                    text: "*.mscx,"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("Ms::MuseScore", "MuseScore Backup Files")
                }
                SmallCheckBox {
                    id: inMscs
                    visible: mscoreMajorVersion > 3 ? true : false // MuseScore 4 and later
                    text: "*.mscs"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("project", "MuseScore developer files")
                }
            } // Column
        } // inFormats

        GridLayout {
            Layout.row: 2
            Layout.column: 0
            Layout.columnSpan: 3
            Layout.margins: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            rowSpacing: 1
            columnSpacing: 1
            columns: 2
            
            Label {
                text: qsTr("Import from") + ":"
                color: sysActivePalette.text 
                opacity: 1
            }
            RowLayout {
                TextField {
                    Layout.preferredWidth: 400
                    id: importFrom
                    text: ""
                    enabled: false
                    //color: sysActivePalette.text
                    color: sysDisabledPalette.shadow
                }
                Button {
                    enabled: true
                    text: qsTr("Browse") + "..."
                    onClicked: {
                        sourceFolderDialog.open()
                    }
                }
            }
            SmallCheckBox {
                id: traverseSubdirs
                Layout.columnSpan: 2
                enabled: true
                text: qsTr("Process Subdirectories")
            } // traverseSubdirs
        } // options Column

        Item {
            //color: "#FFAACC"
            Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
            Layout.columnSpan: 3
            Layout.column: 0
            Layout.row: 3
            Layout.fillWidth: true
            Layout.rightMargin: 10
            Layout.leftMargin: 10
            Layout.topMargin: 5
            Layout.preferredHeight: btnrow.implicitHeight
            RowLayout {
                id: btnrow
                spacing: 5
                anchors.fill: parent
                Button {
                    id: reset
                    text: qsTranslate("QPlatformTheme", "Restore Defaults")
                    onClicked: {
                        resetDefaults()
                    } // onClicked
                } // reset

                Button {
                    id: openlog
                    text: qsTr("View log")
                    onClicked: {
                        workDialog.open()
                    } // onClicked
                } // openLog

                Item { // spacer
                    id: spacer
                    implicitHeight: 10
                    Layout.fillWidth: true
                }
                Button {
                    id: ok
                    enabled: true
                    text: qsTr("Remove!")
                    onClicked: {
                        convert = true;
                        work();

                    } // onClicked
                } // ok
                Button {
                    id: cancel
                    text: /*qsTr("Cancel")*/ qsTranslate("QPlatformTheme", "Close")
                    onClicked: {
                        for (var i = 0; i < importWhat.buttons.length; i++) {
                            if (importWhat.buttons[i].checked) {
                                settings.importWhat = i;
                                break;
                            }
                        }
                        removeExample.parent.Window.window.close();
                    }
                } // Cancel
            } // RowLayout
        } // Item
    } // GridLayout
    //} // Window
    // remember settings
    Settings {
        id: settings
        category: "removeExamplePlugin"
        // in options
        property alias inMscz:  inMscz.checked
        property alias inMscx:  inMscx.checked
        property alias inMsc:   inMsc.checked
        property alias inXml:   inXml.checked
        property alias inMusicXml: inMusicXml.checked
        property alias inMxl:   inMxl.checked
        property alias inMid:   inMid.checked
        property alias inMidi:  inMidi.checked
        property alias inKar:   inKar.checked
        property alias inMd:    inMd.checked
        property alias inPdf:   inPdf.checked
        property alias inCap:   inCap.checked
        property alias inCapx:  inCapx.checked
        property alias inMgu:   inMgu.checked
        property alias inSgu:   inSgu.checked
        property alias inOve:   inOve.checked
        property alias inScw:   inScw.checked
        property alias inBmw:   inBmw.checked
        property alias inBww:   inBww.checked
        property alias inGtp:   inGtp.checked
        property alias inGp3:   inGp3.checked
        property alias inGp4:   inGp4.checked
        property alias inGp5:   inGp5.checked
        property alias inGpx:   inGpx.checked
        property alias inGp:    inGp.checked
        property alias inPtb:   inPtb.checked
        property alias inMsczComma: inMsczComma.checked
        property alias inMscxComma: inMscxComma.checked
        // other options
        property alias travers: traverseSubdirs.checked
        property alias iPath: importFrom.text // import path

        property int importWhat
    }

    FileDialog {
        id: sourceFolderDialog
        title: traverseSubdirs.checked ?
                   qsTr("Select Sources Startfolder"):
                   qsTr("Select Sources Folder")
        selectFolder: true
        folder: Qt.resolvedUrl(importFrom.text);


        onAccepted: {
            importFrom.text = sourceFolderDialog.folder.toString();
        }
        onRejected: {
            console.log("No source folder selected")
        }

    } // sourceFolderDialog

    function urlToPath(urlString) {
        var s;
        if (urlString.startsWith("file:///")) {
            var k = urlString.charAt(9) === ':' ? 8 : 7
            s = urlString.substring(k)
        } else {
            s = urlString
        }
        return decodeURIComponent(s);
    }

    function resetDefaults() {
        inMscx.checked = inXml.checked = inMusicXml.checked = inMxl.checked = inMid.checked =
                inMidi.checked = inKar.checked = inMd.checked = inPdf.checked = inCap.checked =
                inCapx.checked = inMgu.checked = inSgu.checked = inOve.checked = inScw.checked =
                inBmw.checked = inBww.checked = inGp4.checked = inGp5.checked = inGpx.checked =
                inGp.checked = inPtb.checked = inMsczComma.checked = inMscxComma.checked =
                inMscs.checked = false
        traverseSubdirs.checked = false

        // 'uncheck' everything, then 'check' the next few
        inMscz.checked = outPdf.checked = true
    } // resetDefaults

    // flag for abort request
    property bool abortRequested: false

    // dialog to show progress
    Dialog {
        id: workDialog
        modality: Qt.ApplicationModal
        visible: false
        width: 900
        height: 700
        standardButtons: StandardButton.Ok


        ColumnLayout {

            anchors.fill: parent
            spacing: 5
            anchors.topMargin: 10
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            anchors.bottomMargin: 5

            Label {
                id: currentStatus
                Layout.preferredWidth: 600
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                text: qsTr("Pending...")
            }

            ScrollView {
                id: view
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 700
                Layout.maximumWidth: 900
                clip: true

                TextArea {
                    id: resultText
                    //anchors.fill: parent
                    anchors.margins: 5
                    selectByMouse: true
                    selectByKeyboard: true
                    cursorVisible: true
                    readOnly: true
                    focus: true
                    }

                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.position: 0
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                }

        }

        onRejected: {
            abortRequested = true
        }
    }

    function inInputFormats(suffix) {
        var found = false

        for (var i = 0; i < inFormats.extensions.length; i++) {
            if (inFormats.extensions[i].toUpperCase() === suffix.toUpperCase()) {
                found = true
                break
            }
        }
        return found
    }

    // createDefaultFileName
    // remove some special characters in a score title
    // when creating a file name
    function createDefaultFileName(fn, allowWhitespace) {
        if (allowWhitespace===undefined) allowWhitespace=false;
        fn = fn.trim()
        if (!allowWhitespace) fn = fn.replace(/ /g,"_")
        fn = fn.replace(/[\\\/:\*\?\"<>|]/g,"_")
        return fn
    }

    // global list of folders to process
    property var folderList
    // global list of files to process
    property var fileList
    // global list of linked parts to process
    property var excerptsList

    // variable to remember current parent score for parts
    property var curBaseScore

    // cleaned import path of export
    property var importFromPath
    // regxep to filter the files to convert
    property var regexp
    // conversion mode : effectively do the conversion, or preview only
    property bool convert: false

    SystemPalette { id: sysActivePalette; colorGroup: SystemPalette.Active }
    SystemPalette { id: sysDisabledPalette; colorGroup: SystemPalette.Disabled }



    // FolderListModel can be used to search the file system
    FolderListModel {
        id: files
    }

    FileIO {
        id: fileExcerpt
    }

    FileIO {
        id: fileScore // We need two because they they are used from 2 different processes,
        // which could cause threading problems
    }

    QProcess {
        id: procExcerpt
    }

    QProcess {
        id: procScore
    }

    FileIO {
        id: badFile
        source: "example.txt"
    }

    Timer {
        id: processTimer
        interval: 1
        running: false

        // this function processes one file and then
        // gives control back to Qt to update the dialog
        onTriggered: {
            if (fileList.length === 0 || abortRequested) {
                // no more files to process
                workDialog.standardButtons = StandardButton.Ok;
                if (!abortRequested)
                currentStatus.text = qsTr("Done") /*qsTranslate("QWizard", "Done")*/ + ".";  // Gramatically incorrect translation of QWizard::Done in french
                else
                    console.log("abort!");
                return;
            }

            console.log("--Remaing items to convert: "+fileList.length+"--");

            var curFileInfo = fileList.shift();
            var filePath = curFileInfo[0];
            var fileName = curFileInfo[1];
            var fileExt = curFileInfo[2];

            var fileFullPath = filePath + fileName + "." + fileExt;

            resultText.append("%1 Removed".arg(fileFullPath))
            badFile.source = fileFullPath
            badFile.remove()

            workDialog.standardButtons = StandardButton.Ok
        }
    }

    function buildExportPath(dest,tag,value, missing) {
        if (!value || value.trim()==="") {
            if (missing) {
                value=missing;
            } else {
                return dest; // return as such
            }
        }
        else {
        value=createDefaultFileName(value,true); // allow whitespaces
        }
        return dest.replace(tag,value);
    }

    function mkdir(qproc, path) {
        var cmd;
        var res = false;

        // Platform-based command
        switch (Qt.platform.os) {
        case "windows":
            var wpath=path.replace(/\//g,"\\");
            cmd = "cmd /c mkdir \"" + wpath + "\"";
            break;
        default:
            cmd = "/bin/sh -c \"mkdir -p '"+path+"'\"";
        }

        // Execution
        // var res = qproc.waitForStarted(3000);
        // if (res) {
        console.log("-- MKDIR PATH: " + path);
        console.log("-- MKDIR CMD: " + cmd);
        qproc.start(cmd);
        res = qproc.waitForFinished(5000);
        if (res) {
            console.log("-- MKDIR CMD : OK");
        } else {
            console.log("-- MKDIR CMD : ERR");
        }

        // DEBUG
        try {
            console.log("-- MKDIR STDOUT : " + qproc.readAllStandardOutput());
        } catch (err) {
            console.log("--" + err.message);
        }

        // !! "true" doesn't mean it all went right. E.g. calling "cmd /c foobar" will return true even if the foobar" command does not exist !!
        return (res ? true : false);
    }
    // FolderListModel returns what Qt calles the
    // completeSuffix for "fileSuffix" which means everything
    // that follows the first '.' in a file name. (e.g. 'tar.gz')
    // However, this is not what we want:
    // For us the suffix is the part after the last '.'
    // because some users have dots in their file names.
    // Qt::FileInfo::suffix() would get this, but seems not
    // to be available in FolderListModel.
    // So, we need to do this ourselves:
    function getFileSuffix(fileName) {

        var n = fileName.lastIndexOf(".");
        var suffix = fileName.substring(n+1);

        return suffix
    }

    function collectInFormats() {
        inFormats.extensions.length=0;
        if (inMscz.checked) inFormats.extensions.push("mscz")
        if (inMscx.checked) inFormats.extensions.push("mscx")
        if (inXml.checked)  inFormats.extensions.push("xml")
        if (inMusicXml.checked) inFormats.extensions.push("musicxml")
        if (inMxl.checked)  inFormats.extensions.push("mxl")
        if (inMid.checked)  inFormats.extensions.push("mid")
        if (inMidi.checked) inFormats.extensions.push("midi")
        if (inKar.checked)  inFormats.extensions.push("kar")
        if (inMd.checked)   inFormats.extensions.push("md")
        if (inPdf.checked)  inFormats.extensions.push("pdf")
        if (inCap.checked)  inFormats.extensions.push("cap")
        if (inCapx.checked) inFormats.extensions.push("capx")
        if (inMgu.checked)  inFormats.extensions.push("mgu")
        if (inSgu.checked)  inFormats.extensions.push("sgu")
        if (inOve.checked)  inFormats.extensions.push("ove")
        if (inScw.checked)  inFormats.extensions.push("scw")
        if (inBmw.checked)  inFormats.extensions.push("bmw")
        if (inBww.checked)  inFormats.extensions.push("bww")
        if (inGtp.checked)  inFormats.extensions.push("gtp")
        if (inGp3.checked)  inFormats.extensions.push("gp3")
        if (inGp4.checked)  inFormats.extensions.push("gp4")
        if (inGp5.checked)  inFormats.extensions.push("gp5")
        if (inGpx.checked)  inFormats.extensions.push("gpx")
        if (inGp.checked)   inFormats.extensions.push("gp")
        if (inPtb.checked)  inFormats.extensions.push("ptb")
        if (inMsczComma.checked) inFormats.extensions.push(mscoreMajorVersion > 3 ? "mscz~" : "mscz,")
        if (inMscxComma.checked) inFormats.extensions.push("mscx,")
        if (inMscs.checked) inFormats.extensions.push("mscs")
        if (!inFormats.extensions.length)
            console.warn("No input format selected")

        return (inFormats.extensions.length)
    } // collectInFormats

    // This timer contains the function that will be called
    // once the FolderListModel is set.
    Timer {
        id: collectFiles
        interval: 25
        running: false

        // Add all files found by FolderListModel to our list
        onTriggered: {
            // to be able to show what we're doing
            // we must create a list of files to process
            // and then use a timer to do the work
            // otherwise, the dialog window will not update
            for (var i = 0; i < files.count; i++) {

                // if we have a directory, we're supposed to
                // traverse it, so add it to folderList
                if (files.isFolder(i)) {
                    folderList.push(files.get(i, "fileURL"))
                    break
                }
                else if (inInputFormats(getFileSuffix(files.get(i, "fileName")))) {
                    // found a file to process
                    // set file names for in and out files

                    // We need 3 things:
                    // 1) The file path: C:/Path/To/
                    // 2) The file name:            my_score
                    //                                      .
                    // 3) The file's extension:              mscz

                    var fln = files.get(i, "fileName") // returns  "my_score.mscz"
                    var flp = files.get(i, "filePath") // returns  "C:/Path/To/my_score.mscz"

                    var fileExt  = getFileSuffix(fln);  // mscz
                    var fileName = fln.substring(0, fln.length - fileExt.length - 1)
                    var filePath = flp.substring(0, flp.length - fln.length)

                    /// in doubt uncomment to double check
                    // console.log("fln", fln)
                    // console.log("flp", flp)
                    // console.log("fileExt", fileExt)
                    // console.log("fileName", fileName)
                    // console.log("filePath", filePath)

                    var match=true;
                    if (regexp) {
                        // console.log("--Filter files--");
                        // console.log(filterWithRegExp.checked?"--RegExp--":"--Regular--");
                        // console.log("--with \""+contentFilterString.text+"\"--");
                        match=regexp.test(fileName);
                        // console.log("Match RegExp: ", match)
                    } else {
                        // console.log("--Don't filter files--");
                    }

                    if (match) {
                        fileList.push([filePath, fileName, fileExt])
                        break
                    }
                        
                }
            }

            // if folderList is non-empty we need to redo this for the next folder
            if (folderList.length > 0) {
                files.folder = folderList.shift()
                // restart timer for folder search
                collectFiles.running = true
            } else if (fileList.length > 0) {
                // if we found files, start timer do process them
                processTimer.restart();
            }
            else {
                // we didn't find any files
                // report this
                resultText.append(qsTr("No files found"))
                workDialog.standardButtons = StandardButton.Ok
                currentStatus.text = qsTr("Done") /*qsTranslate("QWizard", "Done")*/ + ".";  // Gramatically incorrect translation of QWizard::Done in french
            }
        }
    }

    function work() {

        workDialog.standardButtons = StandardButton.Abort
        currentStatus.text = qsTr("Running...");
        if (resultText.text!=="") resultText.append("---------------------------------");

        if (!collectInFormats()) {
            resultText.append(qsTr("Incomplete in and out format selection "));
            workDialog.standardButtons = StandardButton.Ok
            return;
        }

        workDialog.visible = true

        // initialize global variables
        fileList = []
        folderList = []
        
        // set folder and filter in FolderListModel
        files.folder = importFrom.text

        if (traverseSubdirs.checked) {
            files.showDirs = true
            files.showFiles = true
        }
        else {
            // only look for files
            files.showFiles = true
            files.showDirs = false
        }

        // wait for FolderListModel to update
        // therefore we start a timer that will
        // wait for 25 millis and then start working
        collectFiles.running = true
            
    } // work
} // MuseScore
