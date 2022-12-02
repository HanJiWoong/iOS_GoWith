//
//  PushNotiDataModel.swift
//  GWith
//
//  Created by 한지웅 on 2022/12/02.
//

import Foundation

struct PushNotiDataModel:Codable {
    var interfaceName:String?
    var alarmType:String?
    var locationName:String?
    var memberName:String?
    var rideManagerPhone:String?
    var lineResultId:String?
    
    enum CodingKeys:String,CodingKey {
        case interfaceName = "interface_name"
        case alarmType = "alarm_type"
        case locationName = "location"
        case memberName = "member_name"
        case rideManagerPhone = "ride_manager_phone"
        case lineResultId = "line_result_id"
    }
}
