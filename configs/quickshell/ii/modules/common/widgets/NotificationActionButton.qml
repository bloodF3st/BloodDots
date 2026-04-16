import qs.modules.common
import qs.modules.common.functions
import qs.services
import QtQuick
import Quickshell.Services.Notifications

RippleButton {
    id: button
    property string buttonText
    property string urgency

    implicitHeight: 34
    leftPadding: 15
    rightPadding: 15
    buttonRadius: Appearance.rounding.large
    colBackground: (urgency == NotificationUrgency.Critical) ? Appearance.colors.colSecondaryContainer : ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.5)
    colBackgroundHover: (urgency == NotificationUrgency.Critical) ? Appearance.colors.colSecondaryContainerHover : ColorUtils.applyAlpha(Appearance.colors.colLayer1Hover, 0.65)
    colRipple: (urgency == NotificationUrgency.Critical) ? Appearance.colors.colSecondaryContainerActive : ColorUtils.applyAlpha(Appearance.colors.colLayer1Active, 0.5)

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: (urgency == NotificationUrgency.Critical) ? Appearance.m3colors.m3onSurfaceVariant : Appearance.m3colors.m3onSurface
    }
}