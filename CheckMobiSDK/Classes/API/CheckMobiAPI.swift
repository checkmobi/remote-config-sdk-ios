//
//  CheckMobiAPI.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation
import Moya

let APIProvider = MoyaProvider<CheckMobiAPI>()
let supportedLanguages = Set<String>(["da-DK", "nl-NL", "en-AU", "en-GB", "en-US", "fr-FR", "fr-CA", "de-DE", "it-IT", "pl-PL", "pt-PT", "pt-BR", "ru-RU", "es-ES", "es-US", "sv-SE"])
let serverErrorMessage = "We were unable to reach the server. Please try again later."

enum CheckMobiAPI {
    case getCountries
    case check(phoneNumber: String)
    case validate(phoneNumber: String, validationType: ValidationType)
    case verify(code: String, validationId: String)
}

extension CheckMobiAPI: TargetType {
    var baseURL: URL { return URL(string: "https://api.checkmobi.com")! }
    var path: String {
        switch self {
        case .getCountries:
            return "/v1/countries"
        case .check:
            return "v1/validation/remote-config"
        case .validate:
            return "v1/validation/request"
        case .verify:
            return "v1/validation/verify"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getCountries:
            return .get
        case .check, .validate, .verify:
            return .post
        }
    }
    var task: Task {
        switch self {
        case .getCountries:
            return .requestPlain
        case let .check(phoneNumber):
            return .requestParameters(parameters: ["number": phoneNumber,
                                                   "platform": "ios",
                                                   "language": NSLocale.preferredLanguages[0]],
                                      encoding: JSONEncoding.default)
        case let .validate(phoneNumber, validationType):
            let language = supportedLanguages.contains(Locale.current.identifier) ? Locale.current.identifier : "en-US"
            return .requestParameters(parameters: ["number": phoneNumber,
                                                   "type": validationType.rawValue,
                                                   "platform": "ios",
                                                   "language": language],
                                      encoding: JSONEncoding.default)
        case let .verify(code, validationId):
            return .requestParameters(parameters: ["pin": code,
                                                   "id": validationId,
                                                   "use_server_hangup": true],
                                      encoding: JSONEncoding.default)
        }
    }
    var sampleData: Data {
        return "".utf8Encoded
    }
    var headers: [String: String]? {
        return ["Authorization": CheckMobiManager.shared.apiKey ?? "",
                "Content-type": "application/json"]
    }
}

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
