//
//  CMValidationVC.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import UIKit
import Moya_ObjectMapper
import CoreTelephony

class CMValidationVC: UIViewController {
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var countryCodeLabel: UILabel!
    @IBOutlet var countryNameLabel: UILabel!
    
    weak public var delegate: CheckMobiManagerProtocol?
    private var countryCode: String?
    private var localPhoneNumber = ""
    private var phoneNumber: PhoneNumber?
    private var pickCountryPlaceHolder = "Please pick country"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.retrievePreviousData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContryPickerSegue" {
            if let nc = segue.destination as? UINavigationController,
                let vc = nc.viewControllers.first as? CMCountryPickerVC {
                vc.delegate = self
            }
        } else if segue.identifier == "displayValidation" {
            if let vc = segue.destination as? CMEnterCodeVC {
                vc.phoneNumber = self.phoneNumber
                vc.delegate = self.delegate
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func showVerificationDialogFor(number: String, isValid: Bool) {
        var message = ""
        if isValid {
            message = "Are you sure you want to verify this number: \(number)?"
        } else {
            message = "The number seems to be invalid. Are you sure you want to verify this number: \(number)?"
        }
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let editAction = UIAlertAction(title: "Edit", style: .cancel)
        alertController.addAction(editAction)
        
        let continueAction = UIAlertAction(title: "Continue",
                                           style: .default) { _ in
            self.showMissedCallTutorialIfNecessaryOrContinueFlow()
        }
        alertController.addAction(continueAction)
        self.present(alertController, animated: true)
    }
    
    private func showMissedCallTutorialIfNecessaryOrContinueFlow() {
        if let phoneNumber = self.phoneNumber,
            let validationMethod = phoneNumber.validationMethods?.first,
            validationMethod.type == .missedCall {
            let message = missedCallTutorialText

            let alertController = UIAlertController(title: "",
                                                    message: message,
                                                    preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
                self.requestValidation()
            }
            alertController.addAction(continueAction)
            self.present(alertController, animated: true)
        } else {
            self.requestValidation()
        }
    }
    
    private func requestValidation() {
        if let validationMethod = self.phoneNumber?.validationMethods?
            .first(where: { method -> Bool in
            return method.maxAttempts ?? 0 > 0
        }), let validationType = validationMethod.type {
            let phoneNumber = self.phoneNumber?.E164Format ?? self.localPhoneNumber
            APIProvider.request(.validate(phoneNumber: phoneNumber,
                                          validationType: validationType)) { [weak self] result in
                self?.displayActivityIndicator(shouldDisplay: false)
                switch result {
                case let .success(response):
                    if let validationInfo = try? response.mapObject(ValidationInfo.self) {
                        self?.phoneNumber?.updateWith(validationInfo: validationInfo)
                        self?.performSegue(withIdentifier: "displayValidation",
                                           sender: nil)
                    } else {
                        self?.alert(message: serverErrorMessage)
                    }
                case .failure:
                    self?.alert(message: serverErrorMessage)
                }
            }
        } else {
            self.alert(message: serverErrorMessage)
        }
    }
    
    private func saveData() {
        UserDefaults.standard.set(self.countryCode,
                                  forKey: "CMContryCode")
        UserDefaults.standard.set(self.phoneNumberTextField.text,
                                  forKey: "CMPhoneNumber")
        UserDefaults.standard.set(self.countryCodeLabel.text,
                                  forKey: "CMCountryCodeLabel")
        UserDefaults.standard.set(self.countryNameLabel.text,
                                  forKey: "CMCountryName")
    }
    
    private func retrievePreviousData() {
        if UserDefaults.standard.string(forKey: "CMContryCode") != nil {
            self.countryCode = UserDefaults.standard
                .string(forKey: "CMContryCode")
            self.phoneNumberTextField.text = UserDefaults.standard
                .string(forKey: "CMPhoneNumber")
            self.countryCodeLabel.text = UserDefaults.standard
                .string(forKey: "CMCountryCodeLabel")
            self.countryNameLabel.text = UserDefaults.standard
                .string(forKey: "CMCountryName")
        } else {
            let networkInfo = CTTelephonyNetworkInfo()
            if let carrier = networkInfo.subscriberCellularProvider,
                let isoContryCode = carrier.isoCountryCode?.uppercased(),
                    let callingCode = self.countryCallingCode(countryRegionCode: isoContryCode) {
                self.countryCode = callingCode
                self.countryCodeLabel.text = "+" + callingCode
               
                let countryName = Locale.current.localizedString(forRegionCode: isoContryCode)
                self.countryNameLabel.text = countryName
                self.saveData()
            } else {
                self.countryNameLabel.text = self.pickCountryPlaceHolder
            }
        }
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.delegate?.checkMobiManagerUserDidDismiss()
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if self.countryCodeLabel.text?.isEmpty ?? true {
            self.alert(message: "Please select a country code to proceed.")
        } else if self.phoneNumberTextField.text?.isEmpty ?? true {
            self.alert(message: "Please add a phone number to proceed.")
        } else {
            self.displayActivityIndicator(shouldDisplay: true)
            let digitsPhoneNumber = self.phoneNumberTextField.text ?? ""
            self.localPhoneNumber = "+\(self.countryCode ?? "")\(digitsPhoneNumber)"
            self.phoneNumber = nil
            self.saveData()
            self.view.endEditing(true)
            APIProvider.request(.check(phoneNumber: self.localPhoneNumber)) {
                [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.displayActivityIndicator(shouldDisplay: false)
                switch result {
                case let .success(response):
                    if let phoneNumber = try? response.mapObject(PhoneNumber.self),
                        let formattedPhoneNumber = phoneNumber.formatting {
                        strongSelf.phoneNumber = phoneNumber
                        strongSelf.showVerificationDialogFor(number: formattedPhoneNumber, isValid: true)
                    } else {
                        strongSelf.showVerificationDialogFor(number: strongSelf.localPhoneNumber, isValid: false)
                    }
                case .failure:
                    strongSelf.showVerificationDialogFor(number:
                        strongSelf.localPhoneNumber, isValid: false)
                }
            }
        }
    }
}

extension CMValidationVC: CMCountryPickerVCProtocol {
    func countryPickerVCDidSelect(country: Country) {
        self.countryCode = country.prefix
        self.countryCodeLabel.text = "+" + (country.prefix ?? "")
        self.countryNameLabel.text = country.name
    }
}

extension CMValidationVC {
    func countryCallingCode(countryRegionCode: String) -> String? {
        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
        let countryDialingCode = prefixCodes[countryRegionCode]
        return countryDialingCode
    }
}
