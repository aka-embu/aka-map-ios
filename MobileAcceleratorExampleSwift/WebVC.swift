//
//  webView.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 23/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import Foundation


protocol WebVCDelegate: class {
	func loadedWebSiteName(siteName: String)
}

final class WebVC: UIViewController, UIWebViewDelegate {

	var siteName = ""
	var url: URL?
	weak var webDelegate: WebVCDelegate?

	@IBOutlet weak var webView: UIWebView!
	private var startTime: TimeInterval = 0.0
	private var loadTimeElapsed: TimeInterval = 0.0
	private var alertController: UIAlertController!

	override func viewDidLoad() {
		super.viewDidLoad()

		automaticallyAdjustsScrollViewInsets = false

		guard let url = url else {
			print("URL not set")
			return
		}

		startTime = Date.timeIntervalSinceReferenceDate

		let urlRequest = URLRequest.init(url: url, cachePolicy:.useProtocolCachePolicy, timeoutInterval:60.0)
		webView.loadRequest(urlRequest)
	}

	func flashMessage(message:String, title:String) {
		guard alertController == nil else {
			// alert already showing.  try again soon.
			let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
			DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
				self.flashMessage(message: message, title: title)
			})
			return
		}

		guard view.superview != nil else {
			print("Left webview.  Skipping title: \(title), message: \(message)")
			return
		}

		alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

		present(alertController, animated: true) {
			let delayTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
			DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
				self.dismiss(animated: true) {
					self.alertController = nil
				}
			})
		}
	}

	// MARK: UIWebViewDelegate

	func webViewDidStartLoad(_ webView: UIWebView) {
		// Note: we would like to clear network stats before each new page,
		// but this can be called several times per page (once per frame).
		// Outside the scope of this demo, one could accumulate stats across
		// across frames and store those stats for each URL loaded.
	}

	func webViewDidFinishLoad(_ webView: UIWebView) {
		guard let url = url else {
			print("URL not set")
			return
		}

		if !webView.isLoading {
			loadTimeElapsed = Date.timeIntervalSinceReferenceDate - startTime
			flashMessage(message: url.absoluteString, title: String(format: "%.2fs", loadTimeElapsed))
			webDelegate?.loadedWebSiteName(siteName: (webView.request?.mainDocumentURL?.absoluteString)!)
		}
	}

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        flashMessage(message: "Cannot load page", title:"Offline")
    }

}
