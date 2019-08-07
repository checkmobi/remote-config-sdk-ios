# remote-config-sdk-iOS

[![CI Status](https://img.shields.io/travis/bogdanmatasaru/CheckMobiSDK.svg?style=flat)](https://travis-ci.org/bogdanmatasaru/CheckMobiSDK)
[![Version](https://img.shields.io/cocoapods/v/CheckMobiSDK.svg?style=flat)](https://cocoapods.org/pods/CheckMobiSDK)
[![License](https://img.shields.io/cocoapods/l/CheckMobiSDK.svg?style=flat)](https://cocoapods.org/pods/CheckMobiSDK)
[![Platform](https://img.shields.io/cocoapods/p/CheckMobiSDK.svg?style=flat)](https://cocoapods.org/pods/CheckMobiSDK)

*[CheckMobi][1] Remote Config SDK For iOS*

### Overview

CheckMobi Remote Config SDK for iOS allows the users to integrate CheckMobi validation methods 
on iOS in a very efficient and flexible manner without wasting their time to write the logic for any validation flow.

### Features

- Integration with few lines of code 
- You can change the verification flow directly from the CheckMobi website, on the fly, without deploying a new client version.
- The CheckMobi complete suite of verification products (SMS, Voice, Missed Call) creates a variety of flows that you can test instantly with few lines of code.
- Customize different validation flows by country, operator or even number and split test to validate improvements.
- It's completely open source. In case the API doesn't allow you to customize the UI as you wish, you can anytime clone it and change the code.

## Installation

CheckMobiSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CheckMobiSDK'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Testing

The repo contains a [demo app][2] which can be used to test the product without having to integrate into a new project.

In order to do this just:

- Clone the repo
- Open the project in [Xcode][3]
- Open [ViewController.swift][4] and search for the variable `CheckMobiManager.shared.apiKey` and set it's value/ or input key in interface using UITextField to your CheckMobi Secret Key from web portal.
- Run the project on a device

#### Set the API Secret Key

In order to use the SDK you need in the first time to set the CheckMobi Secret Key from the web portal. You can do this somewhere before calling any SDK method by calling:

*Swift*
```
CheckMobiManager.shared.apiKey = "YOUR_SERET_KEY_HERE"
```
*Objective-C*
```objc
CheckMobiManager.shared.apiKey = @"YOUR_SERET_KEY_HERE";
```

#### Integrate the phone validation process

The first thing you need to do is to check if the user has already verified his number. You can do this like so:

*Swift*
```swift
let phoneNumber = CheckMobiManager.shared.verifiedPhoneNumber
```
*Objective-C*
```objc
NSString *phoneNumber = CheckMobiManager.shared.verifiedPhoneNumber;
```

If `verifiedNumber` is not nil, your user has verified his number and you should allow him to continue using the app otherwise 
you should redirect him to the validation process.

To start a validation process you should add the following lines of code:

*Swift*
```swift
CheckMobiManager.shared.startValidationFrom(viewController: self, delegate: self)
```
*Objective-C*
```objc
[CheckMobiManager.shared startValidationFromViewController:self delegate:self];
```

You should also implement the `CheckMobiManagerProtocol` methods like so:

*Swift*
```swift
public func checkMobiManagerDidValidate(phoneNumber: String) {}
public func checkMobiManagerUserDidDismiss() {}
```
*Objective-C*
```objc
- (void)checkMobiManagerDidValidateWithPhoneNumber:(NSString *)phoneNumber {}
- (void)checkMobiManagerUserDidDismiss {}
```

#### Behind the scene

Behind the scene the SDK is using the [CheckMobi REST API][5]. 

First is doing a call to [Get Remote Config Profile][6] which returns the validation flow for the specified destination as 
configured in the CheckMobi Web Portal.

Then based on the profile received the app it's using the [Request Validation API][7] and [Verify PIN API][8] to implement the desired validation processes. 
   
The select country picker is populated using the information received from [Get Countries API][9].

## Author

checkmobi, support@checkmobi.com

## License

CheckMobiSDK is available under the MIT license. See the LICENSE file for more info.

[1]:https://checkmobi.com/
[2]:https://github.com/checkmobi/remote-config-sdk-ios/tree/master/Example
[3]:https://developer.apple.com/xcode/
[4]:https://github.com/checkmobi/remote-config-sdk-ios/blob/master/Example/CheckMobiSDK/ViewController.swift
[5]:https://checkmobi.com/documentation.html#/overview
[6]:https://checkmobi.com/documentation.html#/remote-config-profile-api
[7]:https://checkmobi.com/documentation.html#/request_validation
[8]:https://checkmobi.com/documentation.html#/verify_pin
[9]:https://checkmobi.com/documentation.html#/countries-list
