import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

Item {
    id: root

 property string realUsername: userModel.lastUser ? userModel.lastUser : "User"

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.Background || "backgrounds/background.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    Item {
        id: leftPanel
        width: root.width * 0.28
        height: root.height
        anchors.left: parent ? parent.left : undefined
        clip: true

        ShaderEffectSource {
            id: blurSource
            sourceItem: backgroundImage
            anchors.fill: parent
            sourceRect: Qt.rect(0, 0, leftPanel.width, leftPanel.height)
        }

        // --- УНИВЕРСАЛЬНЫЙ ШЕЙДЕРНЫЙ БЛЮР БЕЗ ИМПОРТОВ ---
        ShaderEffect {
            anchors.fill: parent
            property variant source: blurSource
            property real blurSize: 0.015

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;
                uniform lowp float qt_Opacity;
                uniform highp float blurSize;
                void main() {
                    highp vec4 sum = vec4(0.0);
                    sum += texture2D(source, vec2(qt_TexCoord0.x - 4.0*blurSize, qt_TexCoord0.y)) * 0.05;
                    sum += texture2D(source, vec2(qt_TexCoord0.x - 3.0*blurSize, qt_TexCoord0.y)) * 0.09;
                    sum += texture2D(source, vec2(qt_TexCoord0.x - 2.0*blurSize, qt_TexCoord0.y)) * 0.12;
                    sum += texture2D(source, vec2(qt_TexCoord0.x - blurSize, qt_TexCoord0.y)) * 0.15;
                    sum += texture2D(source, vec2(qt_TexCoord0.x, qt_TexCoord0.y)) * 0.16;
                    sum += texture2D(source, vec2(qt_TexCoord0.x + blurSize, qt_TexCoord0.y)) * 0.15;
                    sum += texture2D(source, vec2(qt_TexCoord0.x + 2.0*blurSize, qt_TexCoord0.y)) * 0.12;
                    sum += texture2D(source, vec2(qt_TexCoord0.x + 3.0*blurSize, qt_TexCoord0.y)) * 0.09;
                    sum += texture2D(source, vec2(qt_TexCoord0.x + 4.0*blurSize, qt_TexCoord0.y)) * 0.05;
                    gl_FragColor = sum * qt_Opacity;
                }
            "
        }

        Rectangle {
            anchors.fill: parent
            color: "#1A1A1A"
            opacity: 0.45
        }

        Rectangle {
            width: 1; height: parent ? parent.height : 1080
            anchors.right: parent ? parent.right : undefined
            color: "#D4A5C7"; opacity: 0.4
        }
    }

    FontLoader {
        id: preciosaFont
        source: "fonts/" + (config.Font || "Preciosa") + ".ttf"
    }
    Item {
        id: uiContainer
        anchors.left: leftPanel.left; anchors.top: leftPanel.top; anchors.margins: 40
        width: leftPanel.width - 80; height: root.height - 80

        Text {
            id: welcomeText
            anchors.top: uiContainer.top; anchors.left: uiContainer.left; anchors.right: uiContainer.right
            text: "Welcome back, <b>" + root.realUsername + "</b>,<br>what do you want to do today?"
            font.family: preciosaFont.name; font.pixelSize: 20; color: "#D4A5C7"
            wrapMode: Text.Wrap; lineHeight: 1.2
        }

        Column {
            id: clockBlock
            anchors.top: welcomeText.bottom; anchors.topMargin: 35
            anchors.left: uiContainer.left; anchors.right: uiContainer.right; spacing: 5
            Text {
                id: clockTime
                text: Qt.formatTime(new Date(), "hh:mm")
                font.family: preciosaFont.name; font.pixelSize: 58; color: "#D4A5C7"; font.bold: true
            }
            Text {
                id: clockDate
                text: Qt.formatDate(new Date(), "dddd, MMMM d")
                font.family: preciosaFont.name; font.pixelSize: 16; color: "#D4A5C7"; opacity: 0.8
            }
            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: {
                    clockTime.text = Qt.formatTime(new Date(), "hh:mm")
                    clockDate.text = Qt.formatDate(new Date(), "dddd, MMMM d")
                }
            }
        }

        Item {
            id: formBlock
            anchors.top: clockBlock.bottom; anchors.topMargin: 35
            anchors.left: uiContainer.left; anchors.right: uiContainer.right; height: 250; z: 10

            TextField {
                id: usernameField
                anchors.top: formBlock.top; width: formBlock.width; height: 40; text: root.realUsername
                placeholderText: "Username"; font.family: preciosaFont.name; font.pixelSize: 16
                color: usernameField.activeFocus ? "#A2E8B9" : "#D4A5C7"
                placeholderTextColor: Qt.rgba(212/255, 165/255, 199/255, 0.4)
                background: Rectangle {
                    color: "transparent"
                    border.color: usernameField.activeFocus ? "#A2E8B9" : "#D4A5C7"
                    border.width: usernameField.activeFocus ? 2 : 1; radius: 6
                }
            }

            TextField {
                id: passwordField
                anchors.top: usernameField.bottom; anchors.topMargin: 18; width: formBlock.width; height: 40
                placeholderText: "Password"; echoMode: TextInput.Password; font.family: preciosaFont.name; font.pixelSize: 16
                color: passwordField.activeFocus ? "#A2E8B9" : "#D4A5C7"; focus: true
                placeholderTextColor: Qt.rgba(212/255, 165/255, 199/255, 0.4)
                background: Rectangle {
                    color: "transparent"
                    border.color: passwordField.activeFocus ? "#A2E8B9" : "#D4A5C7"
                    border.width: passwordField.activeFocus ? 2 : 1; radius: 6
                }
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(usernameField.text, passwordField.text, sessionList.currentIndex)
                    }
                }
            }

            Rectangle {
                id: sessionSelector
                anchors.top: passwordField.bottom; anchors.topMargin: 18; width: formBlock.width; height: 40
                color: "transparent"; border.color: isOpen ? "#A2E8B9" : "#D4A5C7"; border.width: 1; radius: 6
                property bool isOpen: false
                Text {
                    anchors.left: sessionSelector.left; anchors.leftMargin: 15; anchors.verticalCenter: sessionSelector.verticalCenter
                    text: sessionModel.data(sessionModel.index(sessionList.currentIndex, 0), Qt.DisplayRole) || "Select Session"
                    font.family: preciosaFont.name; font.pixelSize: 14
                    color: sessionSelector.isOpen ? "#A2E8B9" : "#D4A5C7"
                }
                Text {
                    anchors.right: sessionSelector.right; anchors.rightMargin: 15; anchors.verticalCenter: sessionSelector.verticalCenter
                    text: sessionSelector.isOpen ? "▲" : "▼"; font.pixelSize: 10; color: sessionSelector.isOpen ? "#A2E8B9" : "#D4A5C7"
                }
                MouseArea { anchors.fill: parent; onClicked: sessionSelector.isOpen = !sessionSelector.isOpen }
            }

            Button {
                id: loginButton
                anchors.top: sessionSelector.bottom; anchors.topMargin: 18; width: formBlock.width; height: 40
                text: "Enter the Realm"; font.family: preciosaFont.name; font.pixelSize: 16; font.bold: true
                contentItem: Text {
                    text: loginButton.text; font: loginButton.font
                    color: loginButton.hovered ? "#1A1A1A" : "#D4A5C7"
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: loginButton.hovered ? "#D4A5C7" : "transparent"
                    border.color: "#D4A5C7"; border.width: 1; radius: 6; opacity: loginButton.pressed ? 0.8 : 1.0
                }
                onClicked: { sddm.login(usernameField.text, passwordField.text, sessionList.currentIndex) }
            }

            Rectangle {
                id: dropdownMenu
                visible: sessionSelector.isOpen; anchors.top: sessionSelector.bottom; anchors.topMargin: 2
                width: sessionSelector.width; height: Math.min(sessionModel.count * 40, 160)
                color: "#1A1A1A"; border.color: "#D4A5C7"; border.width: 1; radius: 6; z: 99
                ListView {
                    id: sessionList; anchors.fill: parent; model: sessionModel; currentIndex: sessionModel.lastIndex; clip: true
                    delegate: Rectangle {
                        width: dropdownMenu.width; height: 40
                        color: delegateMouse.containsMouse ? Qt.rgba(212/255, 165/255, 199/255, 0.1) : "transparent"
                        Text {
                            anchors.left: parent.left; anchors.leftMargin: 15; anchors.verticalCenter: parent.verticalCenter
                            text: model.name; color: delegateMouse.containsMouse ? "#A2E8B9" : "#D4A5C7"
                            font.family: preciosaFont.name; font.pixelSize: 14
                        }
                        MouseArea {
                            id: delegateMouse; anchors.fill: parent; hoverEnabled: true
                            onClicked: { sessionList.currentIndex = index; sessionSelector.isOpen = false }
                        }
                    }
                }
            }
        }
    }
}
