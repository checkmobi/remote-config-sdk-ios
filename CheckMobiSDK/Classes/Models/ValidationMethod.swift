//
//  ValidationMethod.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation
import ObjectMapper

enum ValidationType: String {
    case sms = "sms"
    case call = "ivr"
    case missedCall = "reverse_cli"
    
    var retryString: String {
        switch self {
        case .sms:
            return "Resend code"
        case .call:
            return "Call Me"
        case .missedCall:
            return"Verify With Missed Call"
        }
    }
}

struct ValidationMethod: Mappable {
    var type: ValidationType?
    var maxAttempts: Int?
    var delay: Int?
    var smsTemplate: String?
    var pinLength: Int?
    
    mutating func mapping(map: Map) {
        type           <- map["type"]
        maxAttempts    <- map["max_attempts"]
        delay          <- map["delay"]
        smsTemplate    <- map["sms_template"]
        pinLength      <- map["pin_length"]
    }
    
    init?(map: Map) {}
}
