//
//  VerificationInfo.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation
import ObjectMapper

struct VerificationInfo: Mappable {
    var validated: Bool = false
    
    mutating func mapping(map: Map) {
        validated <- map["validated"]
    }
    
    init?(map: Map) {}
}
