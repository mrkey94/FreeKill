// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Flickable {
  id: root
  anchors.fill: parent
  property var extra_data: ({})
  property int pid

  signal finish()

  contentHeight: details.height
  ScrollBar.vertical: ScrollBar {}

  ColumnLayout {
    id: details
    width: parent.width - 40
    x: 20

    RowLayout {
      Button {
        text: Backend.translate("Give Flower")
        onClicked: {
          root.givePresent("Flower");
          root.finish();
        }
      }

      Button {
        text: Backend.translate("Give Egg")
        onClicked: {
          if (Math.random() < 0.03) {
            root.givePresent("GiantEgg");
          } else {
            root.givePresent("Egg");
          }
          root.finish();
        }
      }

      Button {
        text: Backend.translate("Give Shoe")
        enabled: Math.random() < 0.3
        onClicked: {
          root.givePresent("Shoe");
          root.finish();
        }
      }

      Button {
        text: Backend.translate("Kick From Room")
        visible: !roomScene.isStarted && roomScene.isOwner
        enabled: pid !== Self.id
        onClicked: {
          ClientInstance.notifyServer("KickPlayer", pid.toString());
          root.finish();
        }
      }
    }

    // TODO: player details
    RowLayout {
      spacing: 16
      Text {
        id: screenName
        font.pixelSize: 18
      }

      Text {
        id: playerGameData
        Layout.fillWidth: true
        font.pixelSize: 18
      }
    }

    TextEdit {
      id: skillDesc

      Layout.fillWidth: true
      font.pixelSize: 18

      readOnly: true
      selectByKeyboard: true
      selectByMouse: false
      wrapMode: TextEdit.WordWrap
      textFormat: TextEdit.RichText
    }
  }

  function givePresent(p) {
    ClientInstance.notifyServer(
      "Chat",
      JSON.stringify({
        type: 2,
        msg: "$!" + p + ":" + pid
      })
    );
  }

  onExtra_dataChanged: {
    if (!extra_data.photo) return;
    screenName.text = "";
    playerGameData.text = "";
    skillDesc.text = "";

    const id = extra_data.photo.playerid;
    if (id == 0) return;
    root.pid = id;

    screenName.text = extra_data.photo.screenName;

    if (!config.observing) {
      const gamedata = JSON.parse(Backend.callLuaFunction("GetPlayerGameData", [id]));
      const total = gamedata[0];
      const win = gamedata[1];
      const run = gamedata[2];
      const winRate = (win / total) * 100;
      const runRate = (run / total) * 100;
      playerGameData.text = Backend.translate("Win=%1 Run=%2 Total=%3").arg(winRate.toFixed(2))
        .arg(runRate.toFixed(2)).arg(total);
    }

    const data = JSON.parse(Backend.callLuaFunction("GetPlayerSkills", [id]));
    data.forEach(t => {
      skillDesc.append("<b>" + Backend.translate(t.name) + "</b>: " + t.description)
    });

    const equips = JSON.parse(Backend.callLuaFunction("GetPlayerEquips", [id]));
    equips.forEach(cid => {
      const t = JSON.parse(Backend.callLuaFunction("GetCardData", [cid]));
      skillDesc.append("--------------------");
      skillDesc.append("<b>" + Backend.translate(t.name) + "</b>: " + Backend.translate(":" + t.name));
    });
  }
}
