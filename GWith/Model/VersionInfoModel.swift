//
//  VersionInfoModel.swift
//  GWith
//
//  Created by 한지웅 on 2022/12/02.
//

import Foundation

struct VersionInfoModel:Codable {
    var osType:String
    var appVersionCode:String
    var appVersionName:String
    var splashID:String
    var fcmToken:String
}
