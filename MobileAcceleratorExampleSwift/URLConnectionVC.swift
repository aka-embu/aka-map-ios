//
//  URLConnectionVC.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 23/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import Foundation

protocol ConnectionVCDelegate: class {
	func loadedConnectionSiteName(siteName: String)
}

final class URLConnectionVC: UIViewController, NSURLConnectionDelegate, NSURLConnectionDataDelegate {

	var siteName: String = ""
	var url: URL?
	weak var connectionDelegate: ConnectionVCDelegate?

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var statusLabel: UILabel!

	private var image: UIImage!
	private var responseData: NSMutableData!
	private var responseStatusCode: NSInteger!

	private var startTime: TimeInterval = 0.0
	private var loadTimeElapsed: TimeInterval = 0.0

	override func viewDidLoad() {
		super.viewDidLoad()

		guard let url = url else {
			print("No URL set")
			return
		}

		startTime = Date.timeIntervalSinceReferenceDate

		let request = URLRequest.init(url: url)

		// Demonstrate using deprecated NSURLConnection
		_ = NSURLConnection.init(request: request, delegate: self)
	}

	// run on main thread due to UIKit reference
	func updateImage() {
		if let responseData = responseData as Data? {
			image = UIImage.init(data: responseData)
			imageView.image = image
		}
	}

	// MARK: NSURLConnection callbacks

	func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
		// called on response or redirect
		if let httpResponse = response as? HTTPURLResponse {
			responseStatusCode = httpResponse.statusCode
		}

		responseData = NSMutableData()
	}

	func connection(_ connection: NSURLConnection, didReceive data: Data) {
		responseData.append(data)
	}

	func connection(_ connection: NSURLConnection, willCacheResponse cachedResponse: CachedURLResponse) -> CachedURLResponse? {
		// return nil to disable the shared cache
		return cachedResponse
	}

	func connectionDidFinishLoading(_ connection: NSURLConnection) {
		let timeNow: TimeInterval = Date.timeIntervalSinceReferenceDate
		loadTimeElapsed = timeNow - startTime

		connectionDelegate!.loadedConnectionSiteName(siteName: self.siteName)

		DispatchQueue.main.async() {
			self.updateImage()
			self.statusLabel.text = String(format: "Status Code: %ld\nSize: %ld bytes", self.responseStatusCode, self.responseData.length)
		}
	}

	func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
		print("NSURLConnection Error: \(error.localizedDescription)")
        DispatchQueue.main.async() {
            self.statusLabel.text = error.localizedDescription
        }
	}
}
