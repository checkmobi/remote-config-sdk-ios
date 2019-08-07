//
//  UIViewController+Alert.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation

extension UIViewController {
    func alert(message: String,
               title: String = "",
               okBlock: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: okBlock)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
    }
}
