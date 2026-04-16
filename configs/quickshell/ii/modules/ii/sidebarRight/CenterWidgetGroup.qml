import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import qs.modules.ii.sidebarRight.notifications
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    radius: Appearance.rounding.normal
    color: ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.45)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.07)

    NotificationList {
        anchors.fill: parent
        anchors.margins: 5
    }
}
