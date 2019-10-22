//
//  AppDelegate.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 23/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import UIKit

//Identifier for registration update notification
let registrationUpdate = "registrationUpdate"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate , VocServiceDelegate {

	var window: UIWindow?
	var akaService: AkaMapProtocol?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

		let akaCommon = AkaCommon.shared()
		akaCommon.debugConsoleEnabled = true
		AkaCommon.configure()

		akaService = AkaMap.shared()

		// example one-time event log
		akaService?.logEvent("APP_LAUNCHED")

		// example timed event log
		let eventName: String = "Sample Event"
		akaService?.startEvent(eventName)
		// ... perform actions over time ...
		akaService?.stopEvent(eventName)

		if (akaService?.state == VOCServiceState.notRegistered) {
			print("MAP not registered, starting registration flow")
		} else {
			print("MAP already registered")
		}

		return true
	}

}
