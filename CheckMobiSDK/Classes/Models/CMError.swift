//
//  CMError.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation
import ObjectMapper

struct CMError: Mappable {
    var code: Int?
    var message: String?
    
    mutating func mapping(map: Map) {
        code  <- map["code"]
        message <- map["error"]
    }
    
    init(map: Map) {}
}
