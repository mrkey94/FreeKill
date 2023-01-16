import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "RoomElement"

Item {
  id: root

  property bool loaded: false

  ListView {
    width: Math.floor(root.width / 98) * 98
    height: parent.height
    anchors.centerIn: parent
    ScrollBar.vertical: ScrollBar {}
    model: ListModel {
      id: packages
    }

    delegate: ColumnLayout {
      Text { text: Backend.translate(name) }
      GridLayout {
        columns: root.width / 98
        Repeater {
          model: JSON.parse(Backend.callLuaFunction("GetGenerals", [name]))
          GeneralCardItem { 
            autoBack: false
            name: modelData
          }
        }
      }
    }
  }

  Button {
    text: Backend.translate("Quit")
    anchors.right: parent.right
    onClicked: {
      mainStack.pop();
    }
  }

  function loadPackages() {
    if (loaded) return;
    let packs = JSON.parse(Backend.callLuaFunction("GetAllGeneralPack", []));
    packs.forEach((name) => packages.append({ name: name }));
    loaded = true;
  }
}