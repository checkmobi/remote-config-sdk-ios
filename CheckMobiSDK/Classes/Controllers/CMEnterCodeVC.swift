//
//  CMEnterCodeVC.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import UIKit
import Moya
import Moya_ObjectMapper
import KAPinField

class CMEnterCodeVC: UIViewController {
    @IBOutlet var incentiveLabel: UILabel!
    @IBOutlet var smsStackView: UIStackView!
    @IBOutlet var callStackView: UIStackView!
    @IBOutlet var missedCallStackView: UIStackView!
    @IBOutlet var sendSMSButton: UIButton!
    @IBOutlet var callMeButton: UIButton!
    @IBOutlet var missedCallButton: UIButton!
    @IBOutlet var codeInputView: KAPinField!
    
    weak public var delegate: CheckMobiManagerProtocol?
    public var phoneNumber: PhoneNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.codeInputView.properties.delegate = self
        self.setupWith(phoneNumber: self.phoneNumber)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
           let _ = self.codeInputView.becomeFirstResponder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupWith(phoneNumber: PhoneNumber) {
        self.navigationItem.title = phoneNumber.formatting
        let typeString = (phoneNumber.validationType == .sms) ? "SMS" : "Call"
        var incentive = "We have sent you an \(typeString) with a code to the number above."
        if (phoneNumber.validationType == .sms) {
            incentive = "We are sending you a missed call.\n The last 4 digits of the incoming call represent the pin number."
        }
        self.incentiveLabel.text = incentive
        self.codeInputView.properties.token = "-"
        self.codeInputView.properties.numberOfCharacters = (phoneNumber.pinLength ?? 4)
        self.setupRetryLayout()
    }
    
    private func setupRetryLayout() {
        self.smsStackView.isHidden = !self.phoneNumber.hasValidationType(.sms)
        self.callStackView.isHidden = !self.phoneNumber.hasValidationType(.call)
        self.missedCallStackView.isHidden = !self.phoneNumber.hasValidationType(.missedCall)
        
        if let methods = self.phoneNumber.validationMethods {
            for method in methods {
                guard let type = method.type else { return }
                let delay = self.phoneNumber.validationDelay ?? 0
                switch type {
                case .sms:
                    self.updateLayoutForMethod(method,
                                               delay: delay,
                                               button: self.sendSMSButton)
                case .call:
                self.updateLayoutForMethod(method,
                                           delay: delay,
                                           button: self.callMeButton)
                case .missedCall:
                self.updateLayoutForMethod(method,
                                           delay: delay,
                                           button: self.missedCallButton)
                }
            }
        }
    }
    
    private func updateLayoutForMethod(_ method: ValidationMethod,
                                       delay: Int,
                                       button: UIButton) {
        if let retriesLeft = method.maxAttempts, retriesLeft > 0 {
            self.setCountDownTimerFor(button: button,
                                      type: method.type,
                                      delay: delay)
        } else {
            button.setTitle("No Retries Left", for: .normal)
            button.isEnabled = false
        }
    }
    
    private func setCountDownTimerFor(button: UIButton,
                                      type: ValidationType?,
                                      delay: Int?) {
        var seconds = delay ?? 0
        Timer.scheduledTimer(withTimeInterval: 1,
                             repeats: true) { timer in
            seconds -= 1
            var buttonTitle = type?.retryString ?? ""
            if seconds == 0 {
                button.setTitle(buttonTitle, for: .normal)
                button.isEnabled = true
                timer.invalidate()
            } else {
                let minutesDisplay = (seconds % 3600) / 60
                let secondsDisplay = (seconds % 3600) % 60
                let formattedSeconds = (secondsDisplay < 10) ? "0\(secondsDisplay)" : "\(secondsDisplay)"
                buttonTitle += " in \(minutesDisplay):\(formattedSeconds)"
                button.isEnabled = false
                button.setTitle(buttonTitle, for: .normal)
            }
        }
    }
    
    private func showMissedCallTutorial() {
        let alertController = UIAlertController(title: "",
                                                message: missedCallTutorialText,
                                                preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
            self.validate(phoneNumber: self.phoneNumber,
                          validationType: .missedCall)
        }
        alertController.addAction(continueAction)
        self.present(alertController, animated: true)
    }
    
    private func validate(phoneNumber: PhoneNumber?,
                          validationType: ValidationType) {
        guard let phoneNumber = phoneNumber?.E164Format else { return }
        self.view.endEditing(true)
        self.displayActivityIndicator(shouldDisplay: true)
        APIProvider.request(.validate(phoneNumber: phoneNumber,
                                      validationType: validationType)) {
                                        [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.displayActivityIndicator(shouldDisplay: false)
            switch result {
            case let .success(response):
                if let validationInfo =
                    try? response.mapObject(ValidationInfo.self) {
                    strongSelf.phoneNumber
                        .updateWith(validationInfo: validationInfo)
                    strongSelf.setupWith(phoneNumber: strongSelf.phoneNumber)
                } else {
                    strongSelf.alert(message: serverErrorMessage)
                }
            case .failure:
                strongSelf.alert(message: serverErrorMessage)
            }
        }
    }
    
    private func handleValidCodeFor(_ phoneNumber: String) {
        UserDefaults.standard.set(phoneNumber,
                                  forKey: "CMVerifiedPhoneNumber")
        self.codeInputView.animateSuccess(with: "👍") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {                         self.dismiss(animated: true, completion: {
                    self.delegate?.checkMobiManagerDidValidate(phoneNumber: phoneNumber)
                })
            }
        }
    }
    
    private func handleInvalidCode() {
        self.alert(message: incorectPinMessage, okBlock: { _ in
            self.codeInputView.text = ""
            self.codeInputView.reloadAppearance()
            DispatchQueue.main.async {
                let _ = self.codeInputView.becomeFirstResponder()
            }
        })
    }
    
    func validate(_ code: String?) {
        guard let validationId = self.phoneNumber.validationId,
            let code = code else { return }
        self.view.endEditing(true)
        self.displayActivityIndicator(shouldDisplay: true)
        APIProvider.request(.verify(code: code,
                                    validationId: validationId)) {
            [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.displayActivityIndicator(shouldDisplay: false)
            switch result {
            case let .success(response):
                if let verificationInfo =
                    try? response.mapObject(VerificationInfo.self), verificationInfo.validated,
                    let phoneNumber = strongSelf.phoneNumber.E164Format {
                    strongSelf.handleValidCodeFor(phoneNumber)
                } else {
                    strongSelf.handleInvalidCode()
                }
            case .failure:
                strongSelf.alert(message: serverErrorMessage)
            }
        }
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.checkMobiManagerUserDidDismiss()
        }
    }
    
    @IBAction func sendSMSButtonPressed(_ sender: Any) {
        self.validate(phoneNumber: self.phoneNumber,
                      validationType: .sms)
    }
    
    @IBAction func callMeButtonPressed(_ sender: Any) {
        self.validate(phoneNumber: self.phoneNumber,
                      validationType: .call)
    }
    
    @IBAction func missedCallButtonPressed(_ sender: Any) {
        self.showMissedCallTutorial()
    }
}

extension CMEnterCodeVC : KAPinFieldDelegate {
    func pinField(_ field: KAPinField, didFinishWith code: String) {
        self.validate(code)
    }
}
