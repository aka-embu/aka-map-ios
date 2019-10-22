//
//  AICVC.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 09/08/2016.
//  Copyright © 2016 akamai. All rights reserved.
//

import Foundation
import AkaCommon

final class AICVC: UIViewController, URLSessionDelegate,URLSessionDataDelegate,URLSessionTaskDelegate {

	var url: URL?

	@IBOutlet weak var labelContentSize: UILabel!
	@IBOutlet weak var labelResponseCode: UILabel!
	@IBOutlet weak var labelURL: UILabel!
	@IBOutlet weak var labelStatus: UILabel!

	@IBOutlet weak var imageView: UIImageView!

	@IBOutlet weak var buttonReload: UIButton!
	@IBOutlet weak var buttonChangeURL: UIButton!

	private var image: UIImage!
	private var responseData: NSMutableData?
	private var responseStatusCode: NSInteger!

	private var startTime: TimeInterval = 0.0
	private var loadTimeElapsed: TimeInterval = 0.0

	override func viewDidLoad() {
		super.viewDidLoad()

		labelURL.text = "URL: \(url?.absoluteString ?? "<no URL>")"
		beginDownload()
	}

	func beginDownload() {
		labelResponseCode.text = "Response Code: ---"
		labelContentSize.text = "Content Size: --- bytes"
		labelStatus.text = "Status: reloading"

		guard let url = url else {
			print("No URL set.")
			return
		}

		startTime = Date.timeIntervalSinceReferenceDate

		// Create config using Mobile Accelerator SDK
		let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.default
		AkaCommon.shared().interceptSessions(with: sessionConfig)

		let session = URLSession.init(configuration: sessionConfig, delegate: self, delegateQueue: nil)

		// Create a request that ignores the system cache. This allows
		// for reloading the image under different network conditions.
		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalCacheData

		let dataTask = session.dataTask(with: request)
		dataTask.resume()
	}

	// run on main thread due to UIKit reference
	func updateImage() {
		if let responseData = responseData as Data? {
			image = UIImage.init(data: responseData)
			imageView.image = image
		}
	}

	@IBAction func tappedReload(_ sender: AnyObject) {
		responseData = nil
		beginDownload()
	}

	@IBAction func tappedChangeURL(_ sender: AnyObject) {
		let alert = UIAlertController(title: "Change URL" , message: "", preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Done", style: .default) { UIAlertAction in
			if let textFields = alert.textFields, textFields.count > 0, let text = textFields[0].text {
				self.url = URL(string: text)
				self.labelURL.text = "URL: \(self.url?.absoluteString ?? "<no URL>")"
				self.beginDownload()
			}
		})

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addTextField(configurationHandler: { (textField) in
			textField.text = self.url?.absoluteString
		})

		present(alert, animated: true,completion: nil)
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
		if let responseData = responseData {
			responseData.append(data)
		}
	}

	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Swift.Void) {
		completionHandler(nil)
	}

	// MARK:  URLSessionTaskDelegate
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		guard error == nil else {
			DispatchQueue.main.async() {
				print("URLSessionTaskDelegate error: \(error.debugDescription)")
				self.labelStatus.text = "Status: \(error.debugDescription)"
			}
			return
		}

		let dateNow = Date()
		loadTimeElapsed = dateNow.timeIntervalSinceReferenceDate - startTime

		DispatchQueue.main.async() {
			self.updateImage()

			let dateFormat = DateFormatter()
			dateFormat.dateFormat = "hh:mm:ss a"

			let dateString = dateFormat.string(from: dateNow)
			if let responseCode = self.responseStatusCode {
				self.labelResponseCode.text = "Response Code: \(responseCode)"
			} else {
				self.labelResponseCode.text = "Response Code: <none>"
			}
			if let responseData = self.responseData {
				self.labelContentSize.text = "Content Size:  \(responseData.length) bytes"
			} else {
				self.labelContentSize.text = "Content Size: <unknown>"
			}
			self.labelStatus.text = "Status: updated \(dateString)\nLoad Time: \(self.loadTimeElapsed * 1000.0) ms"
		}
	}
}
