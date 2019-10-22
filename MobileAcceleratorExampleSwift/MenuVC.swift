//
//  MenuVC.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 23/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import Foundation

final class MenuVC: UIViewController, WebVCDelegate, ConnectionVCDelegate, SessionVCDelegate, UITableViewDelegate, UITableViewDataSource {

	enum MenuOptions: Int {
		case MenuRegister = 0
		case MenuConnection
		case MenuSessionGET
		case MenuSessionPOST
		case MenuWebView
		case MenuQuality
		case MenuAIC
		case MenuLog
		case MenuSettings
		case CountMenuOptions
	}

	@IBOutlet weak var menuTable: UITableView!
	private var sessionType: String = "" // @"GET" or @"POST"
	private var selectedSiteName: String = ""
	private var selectedURL: URL?

	private var urlSampleConnection: String = ""
	private var urlSampleSession: String = ""
	private var urlSampleSessionPOST: String = ""

	private var sharedSettings: AppSettings = AppSettings.sharedInstance

	private var statsArray: [AnyObject] = [SiteStats]()

	override func viewDidLoad() {
		super.viewDidLoad()

		automaticallyAdjustsScrollViewInsets = false

		let photoURL = "https://www.akamai.com/us/en/multimedia/images/callout/akamai-about-who-we-are.jpg?interpolation=lanczos-none&downsize=1680px:*&output-quality=85&akamai-feo=off"

		urlSampleConnection = photoURL
		urlSampleSession = photoURL

		// the following service accepts POST requests and echoes the response in a JSON body.
		urlSampleSessionPOST = "https://postman-echo.com/post"

		resetStats()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		NotificationCenter.default.addObserver(forName: NSNotification.Name(registrationUpdate), object: nil, queue: OperationQueue.main) { (Notification) in
			self.menuTable.reloadData()
		}

	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(registrationUpdate), object: nil)
	}

	// MARK: Various tests
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		// generate a new set of trial stats
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.akaService?.clearStats()

		if segue.identifier == "menuWebSegue" {
			if let webVC = segue.destination as? WebVC {
				webVC.siteName = selectedSiteName
				webVC.url = selectedURL
				webVC.webDelegate = self
			}
		} else if segue.identifier == "menuConnectionSegue" {
			if let connectionVC = segue.destination as? URLConnectionVC {
				connectionVC.siteName = selectedSiteName
				connectionVC.url = selectedURL
				connectionVC.connectionDelegate = self
			}
		} else if segue.identifier == "menuSessionSegue" {
			if let sessionVC = segue.destination as? URLSessionVC {
				sessionVC.sessionType = sessionType
				sessionVC.siteName = selectedSiteName
				sessionVC.url = selectedURL
				sessionVC.sessionDelegate = self
			}
		} else if segue.identifier == "menuAICSegue" {
			if let aicVC = segue.destination as? AICVC {
				aicVC.url = selectedURL
			}
		} else if segue.identifier == "menuLogSegue" {
			if let logVC = segue.destination as? LogVC {
				logVC.stats = statsArray
			}
		}
	}

	func loadWebView() {
		selectedSiteName = AppSettings.sharedInstance.webURL
		selectedURL = URL(string: AppSettings.sharedInstance.webURL)
		performSegue(withIdentifier: "menuWebSegue", sender: self)
	}

	func loadURLConnection() {
		selectedSiteName = "NSURLConnection"
		selectedURL = URL(string: urlSampleConnection)
		performSegue(withIdentifier: "menuConnectionSegue", sender: self)
	}

	func loadURLSessionGET() {
		sessionType = "GET"
		selectedSiteName = "URLSession"
		selectedURL = URL(string: urlSampleSession)
		performSegue(withIdentifier: "menuSessionSegue", sender: self)
	}

	func loadURLSessionPOST() {
		sessionType = "POST"
		selectedSiteName = "URLSession"
		selectedURL = URL(string: urlSampleSessionPOST)
		performSegue(withIdentifier: "menuSessionSegue", sender: self)
	}

	func testQuality() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			let akaService = appDelegate.akaService else {
				print("SDK not running")
				return
		}

		if (akaService.state == VOCServiceState.notRegistered) {
			flashMessage(message:"", title:"User Unregistered" )
			return
		}

		let networkQuality:VocNetworkQuality = akaService.networkQuality()!
        switch (networkQuality.qualityStatus) {
			case .poor:
				flashMessage(message: "", title: "Network Quality: Poor")
				//E.g., could cancel or reduce downloads.
			case .good:
				flashMessage(message:"", title: "Network Quality: Good")
				//E.g., could throttle or lower quality of downloads.
			case .excellent:
				flashMessage(message:"", title: "Network Quality: Excellent")
				//E.g., could download extra content.
			case .unknown:
				flashMessage(message:"", title: "Network Quality: Unknown")
			case .notReady:
				flashMessage(message:"", title: "Network Quality: Not Ready")
		}
	}

	func loadAICTest() {
		selectedURL = URL(string: urlSampleSession)
		performSegue(withIdentifier: "menuAICSegue", sender: self)
	}

	func flashMessage(message:String, title:String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		present(alert, animated: true) {
			let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
			DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
				self.dismiss(animated: true)
			})
		}
	}

	// MARK:  SDK service handling
	func tappedConnect() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			let akaService = appDelegate.akaService else {
				print("MAP SDK uninitialized")
				return
		}

		if (akaService.state != VOCServiceState.notRegistered) {
			unregister()
		}
	}

	func unregister() {
		// ideally the UI would become inactive during deregistration
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.akaService?.unregisterService() { (error: Error?) in
			self.flashMessage(message:"SDK is now inactive", title:"Unregistered!")
			self.menuTable.reloadData()
		}
	}

	// MARK: Site statistics
	func resetStats() {
		self.statsArray = [SiteStats]()
	}

	func addStatsEntryForSiteName(_ siteName: String) {
		guard Thread.isMainThread else {
			DispatchQueue.main.async() {
				self.addStatsEntryForSiteName(siteName)
			}
			return
		}

		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
			let akaService = appDelegate.akaService else {
				return
		}

		let currentPageStats = SiteStats.init()

		currentPageStats.resourceName = siteName
		currentPageStats.connectionType = akaService.statsConnectionType() ?? ""
		currentPageStats.loadTimeFromCache = NSNumber(value: akaService.timeLoadingFromCache())
		currentPageStats.loadTimeFromNetwork = NSNumber(value: akaService.timeLoadingFromNetwork())

		currentPageStats.dlFiles = NSNumber(value: akaService.filesDownloaded())
		currentPageStats.dlBytes = NSNumber(value: akaService.bytesDownloaded())
		currentPageStats.cacheFiles = NSNumber(value: akaService.filesLoadedFromCache())
		currentPageStats.cacheBytes = NSNumber(value: akaService.bytesLoadedFromCache())
		currentPageStats.skippedFiles = NSNumber(value: akaService.filesNotHandled())
		statsArray.append(currentPageStats)
	}

	// MARK:  WebVCDelegate
	func loadedWebSiteName(siteName: String) {
		addStatsEntryForSiteName(siteName)
	}

	// MARK:  ConnectionVCDelegate
	func loadedConnectionSiteName(siteName: String) {
		addStatsEntryForSiteName(siteName)
	}

	// MARK:  SessionVCDelegate
	func loadedSessionSiteName(siteName: String) {
		addStatsEntryForSiteName(siteName)
	}

	// MARK: UITableViewDataSource delegate
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return MenuOptions.CountMenuOptions.rawValue
	}

	// MARK: UITableViewelegate delegate
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "menuCell")!
		cell.selectionStyle = UITableViewCell.SelectionStyle.none

		guard let label = cell.textLabel else {
			return cell
		}

		if let choice = MenuOptions(rawValue: indexPath.row) {
			switch choice {
			case .MenuRegister:
				if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
					appDelegate.akaService?.state == VOCServiceState.notRegistered {
					label.text = "Register (SDK is not running)"
				} else {
					label.text = "Unregister (SDK is running)"
				}
			case .MenuConnection:
				label.text = "NSURLConnection Demo"
			case .MenuSessionGET:
				label.text = "URLSession (GET) Demo"
			case .MenuSessionPOST:
				label.text = "URLSession (POST) Demo"
			case .MenuWebView:
				label.text = "UIWebView Demo"
			case .MenuQuality:
				label.text = "Congestion Test"
			case .MenuAIC:
				label.text = "AIC Test"
			case .MenuLog:
				label.text = "Show Logs"
			case .MenuSettings:
				label.text = "Settings"
			default:
				break
			}
		}
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let choice = MenuOptions(rawValue: indexPath.row) else {
			return
		}
		switch choice {
			case .MenuRegister:
				tappedConnect()
			case .MenuConnection:
				loadURLConnection()
			case .MenuSessionGET:
				loadURLSessionGET()
			case .MenuSessionPOST:
				loadURLSessionPOST()
			case .MenuWebView:
				loadWebView()
			case .MenuQuality:
				testQuality()
			case .MenuAIC:
				loadAICTest()
			case .MenuLog:
				performSegue(withIdentifier: "menuLogSegue", sender: self)
			case .MenuSettings:
				performSegue(withIdentifier: "menuSettingsSegue", sender: self)
			default:
				break
		}
	}
}
