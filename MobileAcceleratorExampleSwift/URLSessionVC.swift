//
//  URLSessionVC.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 23/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import Foundation
import AkaCommon

protocol SessionVCDelegate: class {
	func loadedSessionSiteName(siteName: String)
}

final class URLSessionVC: UIViewController, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {

	var siteName: String = ""
	var sessionType: String = ""
	var url: URL?
	weak var sessionDelegate: SessionVCDelegate?

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
			print("Error: URL not set for URLSessionVC")
			return
		}

		startTime = Date.timeIntervalSinceReferenceDate

		// tell config to use Mobile Accelerator
		let sessionConfig = URLSessionConfiguration.default
		AkaCommon.shared().interceptSessions(with: sessionConfig)

		let session = URLSession.init(configuration: sessionConfig, delegate: self, delegateQueue: nil)

		var request: URLRequest
		if (sessionType == "POST") {
			request = URLRequest(url: url)
			let postParams = "item1=value1&item2=value2"
			request.httpBody = postParams.data(using: String.Encoding.utf8)
			request.httpMethod = "POST"
		} else {
			request = URLRequest(url: url)
		}
		let dataTask = session.dataTask(with: request)
		dataTask.resume()
	}

	// run on main thread due to UIKit reference
	func updateImage() {
		image = UIImage.init(data: responseData as Data)
		imageView.image = image
	}

	// MARK: URLSessionDelegate
	func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
		print("URLSessionDelegate error: \(error.debugDescription)")
	}

	// MARK: URLSessionDataDelegate
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
		if let httpResponse = response as? HTTPURLResponse {
			responseStatusCode = httpResponse.statusCode
		}

		responseData = NSMutableData()
		completionHandler(.allow)
	}

	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		responseData.append(data)
	}

	// MARK: URLSessionTaskDelegate
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		guard error == nil else {
			print("URLSessionTaskDelegate error: \(error!.localizedDescription)")
            DispatchQueue.main.async() {
                self.statusLabel.text = error!.localizedDescription
            }
			return
		}

		guard let sessionDelegate = sessionDelegate else {
			print("No session delegate")
			return
		}

		loadTimeElapsed = Date.timeIntervalSinceReferenceDate - startTime

		sessionDelegate.loadedSessionSiteName(siteName: siteName)

		DispatchQueue.main.async() {
			if (self.sessionType == "POST") {
				if let response = String(data: self.responseData as Data, encoding: String.Encoding.utf8) {
					print("response \(response)")
					self.statusLabel.text = response
				}
			} else {
				self.updateImage()
				self.statusLabel.text = String(format: "Status Code: %ld\nSize: %ld bytes", self.responseStatusCode, self.responseData.length)
			}
		}
	}
}
