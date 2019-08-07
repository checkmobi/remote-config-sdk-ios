//
//  ViewController.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import UIKit
import CheckMobiSDK

class ViewController: UIViewController {
    
    @IBOutlet var apiKeyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiKeyTextField.text = UserDefaults.standard
            .string(forKey: "CMApiKey")
    }
    
    @IBAction func displayValidationButtonPressed(_ sender: Any) {
        UserDefaults.standard.set(self.apiKeyTextField.text,forKey: "CMApiKey")
        CheckMobiManager.shared.apiKey = self.apiKeyTextField.text
        CheckMobiManager.shared.startValidationFrom(viewController: self,
                                                    delegate: self)
    }
}

extension UIViewController: CheckMobiManagerProtocol {
    public func checkMobiManagerDidValidate(phoneNumber: String) {
        self.alert(message: "\(phoneNumber) verified")
    }
    
    public func checkMobiManagerUserDidDismiss() {
        self.alert(message: "check phone number process dismissed")
    }
}

extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
    }
}
