//
//  CheckMobiManager.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol CheckMobiManagerProtocol {
    func checkMobiManagerDidValidate(phoneNumber: String, requestId: String)
    func checkMobiManagerUserDidDismiss()
}

@objcMembers public class CheckMobiManager: NSObject {
    private override init() {}
    
    public static let shared = CheckMobiManager()
    
    public var apiKey: String?
    public var verifiedPhoneNumber: String? {
       return UserDefaults.standard.string(forKey: "CMVerifiedPhoneNumber")
    }
    
    public func resetVerifiedNumber() {
       UserDefaults.standard.removeObject(forKey: "CMVerifiedPhoneNumber")
    }

    public func startValidationFrom(viewController: UIViewController,
                                    delegate: CheckMobiManagerProtocol) {
        let storyboard = UIStoryboard(name: "CMStoryboard", bundle: Bundle(for: CMValidationVC.self))
        if let validationNC: UINavigationController =
            storyboard.instantiateInitialViewController() as? UINavigationController,
            let validationVC =
            validationNC.viewControllers.first as? CMValidationVC {
            validationVC.delegate = delegate
            viewController.present(validationNC, animated: true)
        }
    }
}
