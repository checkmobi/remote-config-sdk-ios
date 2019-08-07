//
//  PhoneNumber.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation
import ObjectMapper

struct PhoneNumber: Mappable {
    var countryCode: Int?
    var countryISOCode: String?
    var carrier: String?
    var isMobile: Bool?
    var E164Format: String?
    var formatting: String?
    var validationMethods: [ValidationMethod]?
    var validationId: String?
    var validationType: ValidationType?
    var validationDelay: Int?
    var pinLength: Int?
    
    mutating func updateWith(validationInfo: ValidationInfo) {
        if let index = self.validationMethods?
            .firstIndex(where: {$0.type == validationInfo.type}) {
            if let attempts = validationMethods?[index].maxAttempts {
                self.validationMethods?[index].maxAttempts = attempts - 1
                self.validationDelay = self.validationMethods?[index].delay
                self.pinLength = self.validationMethods?[index].pinLength
            }
        }
        self.validationType = validationInfo.type
        self.validationId = validationInfo.id
    }
    
    public func hasValidationType(_ type: ValidationType) -> Bool {
       return ((self.validationMethods?.first(where: { $0.type == type })) != nil)
    }
    
    mutating func mapping(map: Map) {
        countryCode           <- map["country_code"]
        countryISOCode        <- map["country_iso_code"]
        carrier               <- map["carrier"]
        isMobile              <- map["is_mobile"]
        E164Format            <- map["e164_format"]
        formatting            <- map["formatting"]
        validationMethods     <- map["settings"]
    }
    
    init?(map: Map) {}
}
