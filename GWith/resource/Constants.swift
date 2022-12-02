//
//  Constants.swift
//  GWith
//
//  Created by 한지웅 on 2022/11/30.
//

import Foundation

struct StoreKeys {
    static let KeysFCMToken = "FCMToken"
}

struct PushNotiDataKeys {
    static let NotiKeyFuncName = "interface_name"
    static let NotiKeyAlarmType = "alarm_type"
    static let NotiKeyLocation = "location"
    static let NotiKeyMemberName = "member_name"
    static let NotiKeyRideManagerPhone = "ride_manager_phone"
    static let NotiKeyLineResultId = "line_result_id"
}

struct PushNotiInterfaceName {
    static let NotiInterfaceNameGetRidingPu = "getRidingPu"
    static let NotiInterfaceNameGetNotRidingPu = "getNotRidingPu"
    static let NotiInterfaceNameGetNotGettingOffPu = "getNotGettingOffPu"
    static let NotiInterfaceNameGetNotRidingMgDv = "getNotRidingMgDv"
    static let NotiInterfaceNameGetNotGettingOffMgDv = "getNotGettingOffMgDv"
}

struct NotificationName {
    static let NotificationNamePushData = "PushDataNoti"
}

struct JSRequestInterfaceName {
    static let Bridge = "WebViewJavascriptBridge"
    static let NfcLaunch = "requestNfcLaunchFromWeb"
    static let CurrentLocation = "requestCurrentLocation"
    static let FCMToken = "requestFCMToken"
    static let TMap = "requestTmapLaunchFromWeb"
    static let VersionInfo = "requestVersionInfoFromWeb"
}
