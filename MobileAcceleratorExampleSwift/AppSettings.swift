//
//  AppSettings.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 23/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import Foundation


final class AppSettings : NSObject {
	private let kSettingsSDKLicense   = "serverSDKLicense"
	private let kSettingsSDKSegments  = "serverSDKSegments"
	private let kSettingsWebURL       = "serverWebURL"
	var userDefaults: UserDefaults    = UserDefaults.standard

	static let sharedInstance = AppSettings()

// MARK: Read/Write properties -- stored to NSUserDefaults
	var serverLicenseKey: String {
		get {
			var license = userDefaults.value(forKey: kSettingsSDKLicense) as? String
			if (license == nil) {
				//TODO: Replace with your SDK API key
				license = "your-license-key-here"
			}
			return license!
		}

		set (newServerLicenseKey) {
			userDefaults.setValue(newServerLicenseKey, forKey: kSettingsSDKLicense)
			userDefaults.synchronize()
		}
	}

	var userSegments: [String] {
		get {
			var segments = userDefaults.value(forKey: kSettingsSDKSegments) as? [String]
			if (segments == nil) {
				//TODO: Replace with your SDK segment IDs
				segments = ["your-segment-here"]
			}
			return segments!
		}

		set (newServerSegments) {
			userDefaults.setValue(newServerSegments, forKey: kSettingsSDKSegments)
			userDefaults.synchronize()
		}
	}

	var webURL: String {
		get {
			var webURL = userDefaults.value(forKey: kSettingsWebURL) as? String
			if (webURL == nil) {
				webURL = "https://www.akamai.com/"
			}
			return webURL!
		}

		set (newWebURL) {
			userDefaults.setValue(newWebURL, forKey: kSettingsWebURL)
			userDefaults.synchronize()
		}
	}
}
