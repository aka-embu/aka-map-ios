//
//  StatCell.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 24/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import Foundation


class StatCell: UITableViewCell {
	@IBOutlet weak var labelResourceName: UILabel!
	@IBOutlet weak var labelNetwork: UILabel!
	@IBOutlet weak var labelCached: UILabel!
	@IBOutlet weak var labelConnectionType: UILabel!
	@IBOutlet weak var labelTimeSaved: UILabel!
}