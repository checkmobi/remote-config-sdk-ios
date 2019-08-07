//
//  ValidationInfo.swift
//  Alamofire
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation
import ObjectMapper

struct ValidationInfo: Mappable {
    var id: String?
    var type: ValidationType?
    
    mutating func mapping(map: Map) {
        id    <- map["id"]
        type  <- map["type"]
    }
    
    init?(map: Map) {}
}
