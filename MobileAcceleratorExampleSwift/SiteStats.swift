//
//  SiteStats.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 24/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import Foundation


class SiteStats {
	var resourceName: String = ""
	var connectionType: String = ""
	var loadTimeFromCache: NSNumber = 0
	var loadTimeFromNetwork: NSNumber = 0
	var dlFiles: NSNumber = 0
	var dlBytes: NSNumber = 0
	var cacheFiles: NSNumber = 0
	var cacheBytes: NSNumber = 0
	var skippedFiles: NSNumber = 0
}