//
//  Country.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation
import ObjectMapper

struct Country: Mappable {
    var name: String?
    var flagUrl: String?
    var prefix: String?
    
    mutating func mapping(map: Map) {
        name        <- map["name"]
        flagUrl     <- map["flag_128"]
        prefix      <- map["prefix"]
    }

    init(map: Map) {}
}
