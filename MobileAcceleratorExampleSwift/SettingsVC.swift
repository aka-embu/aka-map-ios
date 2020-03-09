//
//  SettingsVC.swift
//  MobileAcceleratorExampleSwift
//
//  Created by Waazim Reza on 24/05/2016.
//  Copyright © 2016 Akamai. All rights reserved.
//

import Foundation

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableSettings: UITableView!
	let sharedSettings: AppSettings = AppSettings.sharedInstance

	enum settingsRow: Int {
		case SETTINGS_SERVER_HOST = 0
		case SETTINGS_SDK_API_KEY
		case SETTINGS_SDK_SEGMENTS
		case SETTINGS_WEB_URL
		case NUM_SETTINGS
	}

	// MARK: UITableViewDataSource
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settingsRow.NUM_SETTINGS.rawValue
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell = tableSettings.dequeueReusableCell(withIdentifier: "settingsCell")!
		guard let label = cell.textLabel, let detailLabel = cell.detailTextLabel else {
			return cell
		}

		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let akaConfig = appDelegate.akaService?.config

		if let choice = settingsRow(rawValue: indexPath.row) {
			switch choice {

			case .SETTINGS_SERVER_HOST:
				label.text = "SDK Server (overrides lookup)"
				detailLabel.text = akaConfig?.serverHostOverride?.host ?? "<use lookup>"

			case .SETTINGS_SDK_API_KEY:
				label.text = "API Key"
				detailLabel.text = sharedSettings.serverLicenseKey

			case .SETTINGS_SDK_SEGMENTS:
				label.text = "SDK User Segments"
				detailLabel.text = sharedSettings.userSegments.isEmpty ? "<empty>" : sharedSettings.userSegments.joined(separator: ",")

			case .SETTINGS_WEB_URL:
				label.text = "Web View URL"
				detailLabel.text = sharedSettings.webURL

			default:
				break
			}
		}

		detailLabel.lineBreakMode = .byTruncatingMiddle
		detailLabel.adjustsFontSizeToFitWidth = true

		return cell
	}

	// MARK: UITableViewDelegate
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		acceptModalInputForField(field: settingsRow(rawValue:indexPath.row)!)
	}

	func acceptModalInputForField(field: settingsRow) {
		var title: String = ""
		var message: String = ""
		var oldValue: String = ""

		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let akaService = appDelegate.akaService
		let akaConfig = akaService?.config

		switch field {

		case .SETTINGS_SERVER_HOST:
			title = "SDK Server Override"
			message = "(exclude https://)\n Clear to use lookup server."
			if (akaService?.state != VOCServiceState.notRegistered),
				let serverOverrideHost = akaConfig?.serverHostOverride?.host {
				oldValue = serverOverrideHost
			}

		case .SETTINGS_SDK_API_KEY:
			title = "SDK API Key"
			oldValue = sharedSettings.serverLicenseKey

		case .SETTINGS_SDK_SEGMENTS:
			title = "SDK User Segment(s)"
			message = "Use a comma to separate segments."
			oldValue = sharedSettings.userSegments.joined(separator: ",")

		case .SETTINGS_WEB_URL:
			title = "Web View Demo URL"
			oldValue = sharedSettings.webURL

		default:
			break
		}

		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (alertAction: UIAlertAction!) in
			if let textFields = alert.textFields, textFields.count > 0, let text = textFields[0].text {
				self.handleInput(textInput: text, field: field)
				self.tableSettings.reloadData()
			}
		}))

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
		alert.addTextField(configurationHandler: { (textField: UITextField!) in
			textField.placeholder = oldValue
		})
		present(alert, animated: true, completion: nil)
	}

	func handleInput(textInput: String, field: settingsRow) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let akaService = appDelegate.akaService
		let akaConfig = akaService?.config

		switch field {
		case .SETTINGS_SERVER_HOST:
			akaConfig?.serverHostOverride = textInput.isEmpty ? nil :
				URL(string: "https://\(textInput)")

		case .SETTINGS_SDK_API_KEY:
			sharedSettings.serverLicenseKey = textInput

		case .SETTINGS_SDK_SEGMENTS:
			var updatedSegments: [String] = textInput.components(separatedBy:",")

			// trim whitespace from ends
			var trimmedSegments = [String]()
			for seg in updatedSegments {
				let trimmedSeg = seg.trimmingCharacters(in: NSCharacterSet.whitespaces)
				trimmedSegments.append(trimmedSeg)
			}
			updatedSegments = trimmedSegments

			// save to settings for next registration
			sharedSettings.userSegments = updatedSegments

			// update SDK right now
			if (akaService?.state != VOCServiceState.notRegistered) {
				akaService?.subscribeSegments(Set(updatedSegments))
			}

		case .SETTINGS_WEB_URL:
			sharedSettings.webURL = textInput
		default:
			break
		}
	}
}
