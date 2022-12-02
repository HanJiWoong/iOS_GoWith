//
//  NotiJSInterface.swift
//  GWith
//
//  Created by 한지웅 on 2022/12/02.
//

import Foundation

struct NotiJSInterface:Codable {
    var alarmType:String
    var location:String
    var memberName:String? = nil
    var rideManagerPhone:String? = nil
    var lineResultId:String? = nil
    
    enum CodingKeys:String, CodingKey{
        case alarmType = "alaram_type"
        case location = "location"
        case memberName = "member_name"
        case rideManagerPhone = "ride_manager_phone"
        case lineResultId = "line_result_id"
    }
}
