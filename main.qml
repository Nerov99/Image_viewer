import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Window 2.5
import QtQuick.Dialogs 1.3
import Qt.labs.folderlistmodel 2.15
import Qt.labs.qmlmodels 1.0

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("Image viewer")

    FileDialog {
        id: fileDialog
        title: "Select a folder"
        folder: shortcuts.home
        selectFolder: true
        onAccepted: {}
        onRejected: fileDialog.visible = false
    }

    FolderListModel {
        id: folderModel
        showDirs: false
        nameFilters: ["*.jpg", "*.png", "*.jpeg"]
        folder: fileDialog.fileUrl
    }

    Image {
        id: tempImage
        anchors.centerIn: parent
        z: 2
        width:  parent.width / 1.2
        height: parent.height / 1.2
        visible: false
        MouseArea{
            anchors.fill:parent
            onClicked: {
                tempImage.visible = false
            }
        }
    }

    ListView {
        id: listView
        visible: false
        spacing: 2
        height: root.height - menuBar.height
        anchors{
            left: parent.left
            right: parent.right
            bottom: parent.bottom

        }
        ScrollBar.vertical: ScrollBar {
                active: true
        }
        orientation: Qt.Vertical
        model: folderModel
        delegate:
            Image {
            id: listImage
            x: root.width / 4
            z: 1
            width:  root.width / 2
            height: root.height / 2
            source: folderModel.get(index, "fileURL")
            MouseArea{
                anchors.fill:parent
                onClicked: {
                    tempImage.source = listImage.source
                    tempImage.visible = (tempImage.visible == true) ? false : true
                }
            }
        }
    }

    GridView {
        id: gridView
        clip: true
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        visible: false
        model: folderModel
        ScrollBar.vertical: ScrollBar {
            active: true
        }
        cellWidth: root.width / 3
        cellHeight: root.height / 3
        delegate:
            Rectangle {
                        id: gridRect
                        visible: true
                        z: 1
                        width: gridView.cellWidth * 0.99
                        height: gridView.cellHeight * 0.99

                        Image {
                            id: gridImage
                            anchors.fill: parent
                            width:  parent.width
                            height: parent.height
                            source: folderModel.get(index, "fileURL")
                            MouseArea{
                                anchors.fill:parent
                                onClicked: {
                                    tempImage.source = gridImage.source
                                    tempImage.visible = (tempImage.visible == true) ? false : true
                                }
                            }
                        }
        }
    }

    PathView {
       id: pathView
       anchors{
       fill: parent
       bottomMargin: root.height / 4
       topMargin: root.height / 4
       }
       pathItemCount: 7
       preferredHighlightBegin: 0.5
       preferredHighlightEnd: 0.5
       highlightRangeMode: PathView.StrictlyEnforceRange
       visible: false
       model: folderModel
       MouseArea{
           anchors.fill: parent
           onWheel:
           {
               if( wheel.angleDelta.y < 0 ) pathView.incrementCurrentIndex();
               else pathView.decrementCurrentIndex();
           }
       }

       delegate: Component {
           id: delegate
           Item {
               width: root.width / 2.5; height: root.height / 2.5
               scale: PathView.iconScale
               opacity: PathView.iconOpacity
               z: PathView.iconOrder
               Image {
                   id: pathViewImage
                   anchors.fill: parent
                   source: folderModel.get(index, "fileURL")
                   MouseArea{
                       anchors.fill:parent
                       onClicked: {
                           tempImage.source = pathViewImage.source
                           tempImage.visible = (tempImage.visible == true) ? false : true
                       }
                   }
               }
           }
       }

       path: Path {
           startX: 0; startY: pathView.height/2
           PathAttribute { name: "iconScale"; value: 0.2 }
           PathAttribute { name: "iconOpacity"; value: 10.2 }
           PathAttribute { name: "iconOrder"; value: 0 }
           PathLine {x: pathView.width / 2; y: pathView.height/2 }
           PathAttribute { name: "iconScale"; value: 1.2 }
           PathAttribute { name: "iconOpacity"; value: 1 }
           PathAttribute { name: "iconOrder"; value: 8 }
           PathLine {x: pathView.width; y: pathView.height/2 }
       }
   }

    menuBar: MenuBar {
       id: menuBar
        Menu {
            title: qsTr("&File")

            MenuItem {
                text: qsTr("&Open...")
                onClicked: {
                    fileDialog.open();
                }
            }

            MenuItem {
                text: qsTr("&Quit")

                onClicked: {
                    Qt.quit();
                }
            }
        }

        Menu {
            title: qsTr("&Display mode")

            MenuItem {
                text: qsTr("&List")
                onClicked: {
                    listView.visible = true;
                    gridView.visible = false;
                    pathView.visible = false;
                }
            }

            MenuItem {
                text: qsTr("&Table")
                onClicked: {
                    listView.visible = false;
                    gridView.visible = true;
                    pathView.visible = false;
                }
            }

            MenuItem {
                text: qsTr("&PathView")
                onClicked: {
                    listView.visible = false;
                    gridView.visible = false;
                    pathView.visible = true;
                }
            }
        }
   }
}
