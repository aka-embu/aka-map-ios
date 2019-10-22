//
//  LogVC.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 23/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import Foundation

final class LogVC : UIViewController, UITableViewDelegate, UITableViewDataSource {


	@IBOutlet weak var tableLogs: UITableView!
	var stats: [AnyObject] = [SiteStats]()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.tableLogs.delegate = self
		self.tableLogs.dataSource = self
	}

	// MARK:  UITableViewDataSource

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (self.stats.count)
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		assert(indexPath.row < self.stats.count)

		let stats: SiteStats = self.stats[indexPath.row] as! SiteStats

		let cell : StatCell = self.tableLogs.dequeueReusableCell(withIdentifier: "statCell") as! StatCell

		cell.labelResourceName.text = stats.resourceName

		let bytesCached: Double = stats.cacheBytes.doubleValue
		let bytesDownloaded: Double = stats.dlBytes.doubleValue

		let secondsFromCache: Double = stats.loadTimeFromCache.doubleValue
		let secondsFromNetwork: Double = stats.loadTimeFromNetwork.doubleValue

		cell.labelNetwork.text = String(format: "Network: \(stats.dlFiles) requests, \(stats.dlBytes) bytes, %.0f ms",secondsFromNetwork*1000.0)
		cell.labelCached.text = String(format: "Cached: \(stats.cacheFiles) requests, \(stats.cacheBytes) bytes, %.0f ms",  secondsFromCache*1000.0)
		cell.labelConnectionType.text = String(format: "Type: %@", stats.connectionType)

		let secondsPerByteNetwork: Double = (bytesDownloaded>0) ? secondsFromNetwork/bytesDownloaded : 0
		let secondsIfCacheDataWasNetworked: Double = bytesCached * secondsPerByteNetwork
		var timeSaved: Double = secondsIfCacheDataWasNetworked // ideally time saved = secondsIfCacheDataWasNetworked (time it would have taken) - secondsFromCache (time actually taken)

		if timeSaved < 0 {
			timeSaved = 0
		}

		cell.labelTimeSaved.text = String(format: "format: Saved: %.1f ms", timeSaved * 1000)

		if indexPath.row % 2 == 0 {
			cell.backgroundColor = UIColor.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
		} else {
			cell.backgroundColor = UIColor.white
		}

		return cell


	}
}
