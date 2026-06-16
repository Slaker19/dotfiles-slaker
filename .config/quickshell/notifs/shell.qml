//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Services.Mpris

ShellRoot {
  id: root
  property bool panelOpen: false
  property bool dndEnabled: false
  property var primaryScreen: Quickshell.screens[0]


  NotificationServer {
    id: notifServer
    keepOnReload: true
    persistenceSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    imageSupported: true
    actionsSupported: true

    onNotification: (notif) => {
      notif.tracked = true;
      notifList.insert(0, { notification: notif });
      if (!dndEnabled && notif.expireTimeout > 0) {
        toastQueue.append({ notification: notif });
      }
    }
  }

  ListModel { id: notifList }
  ListModel { id: toastQueue }

  // Toast popup window - top right
  PanelWindow {
    id: toastWin
    screen: root.primaryScreen
    visible: toastQueue.count > 0
    WlrLayershell.layer: WlrLayer.Overlay
    anchors.top: true
    anchors.right: true
    WlrLayershell.margins: 52
    width: 380
    height: Math.min(toastContent.height + 16, 500)
    exclusiveZone: 0
    color: "transparent"

    ColumnLayout {
      id: toastContent
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 4 }
      spacing: 6

      Repeater {
        model: toastQueue

        delegate: Item {
          id: toastItem
          Layout.fillWidth: true
          height: 86
          opacity: 0

          property var notification: model.notification

          NumberAnimation {
            target: toastItem; property: "opacity"
            from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic
            running: true
          }

          Timer {
            running: true
            interval: Math.max(4000, (notification.expireTimeout || 5) * 1000)
            onTriggered: {
              const idx = toastQueue.indexOf(model);
              if (idx >= 0) toastQueue.remove(idx);
            }
          }

          Rectangle {
            anchors.fill: parent
            radius: 14
            color: "#f01a1a2e"
            border { color: "#1a7b3aed"; width: 1 }

            ColumnLayout {
              anchors { fill: parent; margins: 10 }
              spacing: 4

              RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                  text: ""
                  color: "#bb86fc"
                  font { family: "JetBrains Mono Nerd Font"; pixelSize: 14 }
                }
                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 2
                  Text {
                    text: notification.summary || ""
                    color: "#cdd6f4"
                    font { family: "JetBrains Mono Nerd Font"; pixelSize: 13; weight: Font.Bold }
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                  }
                  Text {
                    text: notification.body || ""
                    color: "#a6adc8"
                    font { family: "JetBrains Mono Nerd Font"; pixelSize: 12 }
                    elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.Wrap
                    Layout.fillWidth: true
                  }
                }
                MouseArea {
                  width: 22; height: 22
                  Rectangle {
                    anchors.fill: parent; radius: 11
                    color: parent.containsMouse ? "#30f38ba8" : "transparent"
                    Text {
                      anchors.centerIn: parent
                      text: "×"; color: "#f38ba8"
                      font { family: "JetBrains Mono Nerd Font"; pixelSize: 14 }
                    }
                  }
                  onClicked: {
                    notification.dismiss();
                    const idx = toastQueue.indexOf(model);
                    if (idx >= 0) toastQueue.remove(idx);
                  }
                }
              }

              Rectangle {
                height: 2; radius: 1
                Layout.fillWidth: true
                color: notification.urgency === 2 ? "#f38ba8" :
                       notification.urgency === 0 ? "#a6e3a1" : "#bb86fc"
              }
            }
          }
        }
      }
    }
  }

  // Notification panel - right sidebar
  PanelWindow {
    id: panelWin
    screen: root.primaryScreen
    visible: panelOpen
    WlrLayershell.layer: WlrLayer.Overlay
    anchors.top: true
    anchors.bottom: true
    anchors.right: true
    WlrLayershell.margins: 8
    width: 420
    exclusiveZone: 0
    color: "transparent"

    property real slideOffset: 420

    NumberAnimation on slideOffset {
      from: 420; to: 0
      duration: 350; easing.type: Easing.OutCubic
      running: panelOpen
      onFinished: if (!panelOpen) panelWin.slideOffset = 420
    }

    Rectangle {
      anchors.fill: parent
      anchors.leftMargin: -panelWin.slideOffset
      color: "#f51a1a2e"
      border { color: "#1a7b3aed"; width: 1 }
      radius: 18
      clip: true

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // Header
        Rectangle {
          Layout.fillWidth: true
          height: 44; color: "transparent"
          RowLayout {
            anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 6
            Text {
              text: "  Notifications"
              color: "#cdd6f4"
              font { family: "JetBrains Mono Nerd Font"; pixelSize: 15; weight: Font.Bold }
            }
            Item { Layout.fillWidth: true }
            // Clear all
            Rectangle {
              width: 28; height: 28; radius: 14
              color: mClear.containsMouse ? "#20f38ba8" : "transparent"
              Text {
                anchors.centerIn: parent
                text: ""; color: "#f38ba8"
                font { family: "JetBrains Mono Nerd Font"; pixelSize: 13 }
              }
              MouseArea {
                id: mClear; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: {
                  for (let i = 0; i < notifList.count; i++)
                    notifList.get(i).notification.dismiss();
                  notifList.clear();
                }
              }
            }
            // Close
            Rectangle {
              width: 28; height: 28; radius: 14
              color: mClose.containsMouse ? "#207b3aed" : "transparent"
              Text {
                anchors.centerIn: parent
                text: ""; color: "#cdd6f4"
                font { family: "JetBrains Mono Nerd Font"; pixelSize: 13 }
              }
              MouseArea {
                id: mClose; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: panelOpen = false
              }
            }
          }
        }

        // DND Toggle
        Rectangle {
          Layout.fillWidth: true; height: 38; radius: 10
          color: "#147b3aed"
          RowLayout {
            anchors { fill: parent; leftMargin: 10; rightMargin: 6 }
            Text {
              text: "  Do Not Disturb"
              color: "#a6adc8"
              font { family: "JetBrains Mono Nerd Font"; pixelSize: 12 }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
              width: 40; height: 20; radius: 10
              color: dndToggle.containsMouse ? "#507b3aed" : "#307b3aed"
              Rectangle {
                width: 16; height: 16; radius: 8; color: "#bb86fc"
                anchors.verticalCenter: parent.verticalCenter
                x: root.dndEnabled ? parent.width - width - 2 : 2
                Behavior on x { NumberAnimation { duration: 150 } }
              }
              MouseArea {
                id: dndToggle; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: root.dndEnabled = !root.dndEnabled
              }
            }
          }
        }

        // Media Player
        Rectangle {
          id: mprisBox
          Layout.fillWidth: true
          height: 74
          radius: 14; color: "#12121e"
          border { color: "#0a7b3aed"; width: 1 }
          clip: true

          RowLayout {
            anchors.fill: parent; anchors.margins: 8; spacing: 8
            visible: Mpris.players.length > 0
            Repeater {
              model: Mpris.players
              delegate: RowLayout {
                Layout.fillWidth: true; spacing: 8
                Rectangle {
                  width: 48; height: 48; radius: 10; color: "#1a7b3aed"
                  Image {
                    anchors.fill: parent
                    source: modelData.trackArtUrl || ""
                    fillMode: Image.PreserveAspectCrop; asynchronous: true
                    visible: modelData.trackArtUrl !== ""
                  }
                  Text {
                    anchors.centerIn: parent
                    text: ""
                    font { family: "JetBrains Mono Nerd Font"; pixelSize: 20 }
                    color: "#bb86fc"; visible: modelData.trackArtUrl === ""
                  }
                }
                ColumnLayout {
                  Layout.fillWidth: true; spacing: 1
                  Text {
                    text: modelData.trackTitle || "No track"
                    color: "#cdd6f4"
                    font { family: "JetBrains Mono Nerd Font"; pixelSize: 13; weight: Font.Bold }
                    elide: Text.ElideRight; Layout.fillWidth: true
                  }
                  Text {
                    text: modelData.trackArtist || ""
                    color: "#a6adc8"
                    font { family: "JetBrains Mono Nerd Font"; pixelSize: 11 }
                    elide: Text.ElideRight; Layout.fillWidth: true
                  }
                }
                Row {
                  spacing: 4; Layout.alignment: Qt.AlignVCenter
                  Rectangle {
                    width: 28; height: 28; radius: 14
                    color: mPrev.containsMouse ? "#207b3aed" : "transparent"
                    Text {
                      anchors.centerIn: parent; text: ""; color: "#bb86fc"
                      font { family: "JetBrains Mono Nerd Font"; pixelSize: 12 }
                    }
                    MouseArea {
                      id: mPrev; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                      onClicked: modelData.previous()
                    }
                  }
                  Rectangle {
                    width: 32; height: 32; radius: 16
                    color: mPlay.containsMouse ? "#307b3aed" : "#1a7b3aed"
                    Text {
                      anchors.centerIn: parent
                      text: modelData.isPlaying ? "" : ""; color: "#bb86fc"
                      font { family: "JetBrains Mono Nerd Font"; pixelSize: 14 }
                    }
                    MouseArea {
                      id: mPlay; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                      onClicked: modelData.togglePlaying()
                    }
                  }
                  Rectangle {
                    width: 28; height: 28; radius: 14
                    color: mNext.containsMouse ? "#207b3aed" : "transparent"
                    Text {
                      anchors.centerIn: parent; text: ""; color: "#bb86fc"
                      font { family: "JetBrains Mono Nerd Font"; pixelSize: 12 }
                    }
                    MouseArea {
                      id: mNext; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                      onClicked: modelData.next()
                    }
                  }
                }
              }
            }
          }

          Text {
            anchors.centerIn: parent
            text: "  No media playing"
            color: "#6c7086"
            font { family: "JetBrains Mono Nerd Font"; pixelSize: 12 }
            visible: Mpris.players.length === 0
          }
        }

        // Volume control
        Rectangle {
          Layout.fillWidth: true; height: 36; radius: 10; color: "#12121e"
          border { color: "#0a7b3aed"; width: 1 }
          RowLayout {
            anchors.fill: parent; anchors.margins: 8; spacing: 8
            Text {
              text: ""
              color: "#bb86fc"
              font { family: "JetBrains Mono Nerd Font"; pixelSize: 13 }
            }
            Rectangle {
              Layout.fillWidth: true; height: 6; radius: 3; color: "#2a7b3aed"
              property real vol: 0.5
              Rectangle {
                height: parent.height; radius: 3
                color: "#bb86fc"
                width: parent.width * parent.vol
              }
              MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onPressed: (mouse) => {
                  parent.vol = Math.max(0, Math.min(1, mouse.x / width));
                  Quickshell.exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (parent.vol * 100).toFixed(0) + "%");
                }
                onPositionChanged: (mouse) => {
                  parent.vol = Math.max(0, Math.min(1, mouse.x / width));
                  Quickshell.exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (parent.vol * 100).toFixed(0) + "%");
                }
              }
            }
          }
        }

        // Brightness control
        Rectangle {
          Layout.fillWidth: true; height: 36; radius: 10; color: "#12121e"
          border { color: "#0a7b3aed"; width: 1 }
          RowLayout {
            anchors.fill: parent; anchors.margins: 8; spacing: 8
            Text {
              text: ""
              color: "#f9e2af"
              font { family: "JetBrains Mono Nerd Font"; pixelSize: 13 }
            }
            Rectangle {
              Layout.fillWidth: true; height: 6; radius: 3; color: "#2a7b3aed"
              property real bri: 0.7
              Rectangle {
                height: parent.height; radius: 3
                color: "#f9e2af"
                width: parent.width * parent.bri
              }
              MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onPressed: (mouse) => {
                  parent.bri = Math.max(0, Math.min(1, mouse.x / width));
                  Quickshell.exec("brightnessctl s " + (parent.bri * 100).toFixed(0) + "%");
                }
                onPositionChanged: (mouse) => {
                  parent.bri = Math.max(0, Math.min(1, mouse.x / width));
                  Quickshell.exec("brightnessctl s " + (parent.bri * 100).toFixed(0) + "%");
                }
              }
            }
          }
        }

        // Notification list
        Rectangle {
          Layout.fillWidth: true; Layout.fillHeight: true; radius: 12
          color: "transparent"; clip: true
          ListView {
            id: notifListView
            anchors.fill: parent; anchors.margins: 2
            model: notifList; spacing: 4; clip: true
            delegate: Rectangle {
              width: notifListView.width
              height: notifItem.height + 14
              radius: 10; color: "#12121e"
              border { color: "#0a7b3aed"; width: 1 }
              property var notification: model.notification

              ColumnLayout {
                id: notifItem
                anchors { fill: parent; margins: 8 }
                spacing: 4

                RowLayout {
                  Layout.fillWidth: true; spacing: 6
                  Text {
                    text: notification.appName || ""
                    color: "#bb86fc"
                    font { family: "JetBrains Mono Nerd Font"; pixelSize: 11; weight: Font.Bold }
                  }
                  Text {
                    text: notification.summary || ""
                    color: "#cdd6f4"
                    font { family: "JetBrains Mono Nerd Font"; pixelSize: 12; weight: Font.Bold }
                    elide: Text.ElideRight; Layout.fillWidth: true
                  }
                  Item { Layout.fillWidth: true }
                  Rectangle {
                    width: 20; height: 20; radius: 10
                    color: dBtn.containsMouse ? "#30f38ba8" : "transparent"
                    Text {
                      anchors.centerIn: parent; text: "×"; color: "#f38ba8"
                      font { family: "JetBrains Mono Nerd Font"; pixelSize: 12 }
                    }
                    MouseArea {
                      id: dBtn; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        notification.dismiss();
                        notifList.remove(index);
                      }
                    }
                  }
                }

                Text {
                  text: notification.body || ""
                  color: "#a6adc8"
                  font { family: "JetBrains Mono Nerd Font"; pixelSize: 12 }
                  wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight
                  Layout.fillWidth: true
                  visible: notification.body !== ""
                }
              }
            }
          }

          Text {
            anchors.centerIn: parent
            text: "  No notifications"
            color: "#6c7086"
            font { family: "JetBrains Mono Nerd Font"; pixelSize: 13 }
            visible: notifList.count === 0
          }
        }
      }
    }
  }

  IpcHandler {
    target: "notifs"
    function toggle() { root.panelOpen = !root.panelOpen; }
    function open() { root.panelOpen = true; }
    function close() { root.panelOpen = false; }
  }

}
