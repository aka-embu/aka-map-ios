//
//  SettingsVC.m
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 2/2/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import <AkaMap/AkaMap.h>

#import "SettingsVC.h"
#import "AppDelegate.h"
#import "AppSettings.h"

@interface SettingsVC ()

@property (nonatomic, strong) AppSettings *sharedSettings;

@end

@implementation SettingsVC

typedef enum {
	SETTINGS_SERVER_HOST = 0,
    SETTINGS_SDK_API_KEY,
    SETTINGS_SDK_SEGMENTS,
    SETTINGS_WEB_URL,
    NUM_SETTINGS
} settingsRow;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sharedSettings = [AppSettings sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_SETTINGS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableSettings dequeueReusableCellWithIdentifier:@"settingsCell"];

    switch (indexPath.row) {
        case SETTINGS_SERVER_HOST: {
            cell.textLabel.text = @"SDK Server (overrides lookup)";
			NSString *serverOverride = appDelegate().akaService.config.serverHostOverride.host;
			cell.detailTextLabel.text = serverOverride ? : @"<use lookup>";
			break;
		}
        case SETTINGS_SDK_API_KEY:
            cell.textLabel.text = @"API Key";
            cell.detailTextLabel.text = self.sharedSettings.serverLicenseKey;
            break;
        case SETTINGS_SDK_SEGMENTS:
            cell.textLabel.text = @"SDK User Segments";
            if (! self.sharedSettings.userSegments) {
                cell.detailTextLabel.text = @"<empty>";
            } else {
                cell.detailTextLabel.text = [self.sharedSettings.userSegments componentsJoinedByString:@","];
            }
            break;
        case SETTINGS_WEB_URL:
            cell.textLabel.text = @"Web View URL";
            cell.detailTextLabel.text = self.sharedSettings.webURL;
            break;
    }

    cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;

    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self acceptModalInputForField:(settingsRow)indexPath.row];
}

- (void) acceptModalInputForField:(settingsRow)field
{
    NSString *title;
    NSString *message;
    NSString *oldValue;
    switch (field) {
        case SETTINGS_SERVER_HOST:
            title = @"SDK Server Override";
            message = @"(exclude https://)\nClear to use lookup server.";
            oldValue = appDelegate().akaService.config.serverHostOverride.host;
            break;
        case SETTINGS_SDK_API_KEY:
            title = @"SDK API Key";
            oldValue = self.sharedSettings.serverLicenseKey;
            break;
        case SETTINGS_SDK_SEGMENTS:
            title = @"SDK User Segment(s)";
			message = @"Use a comma to separate segments.";
            oldValue = [self.sharedSettings.userSegments componentsJoinedByString:@","];
            break;
        case SETTINGS_WEB_URL:
            title = @"Web View Demo URL";
            oldValue = self.sharedSettings.webURL;
            break;
        default:
            return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *textField = alert.textFields[0];
        [self handleInput:textField.text forField:field];
        [self.tableSettings reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = oldValue;
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) handleInput:(NSString *)textInput forField:(settingsRow)field
{
    switch (field) {
		case SETTINGS_SERVER_HOST:
			if ([textInput isEqualToString:@""]) {
				appDelegate().akaService.config.serverHostOverride = nil;
			} else {
				NSURL *serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", textInput]];
				appDelegate().akaService.config.serverHostOverride = serverURL;
			}
			break;
        case SETTINGS_SDK_API_KEY:
            self.sharedSettings.serverLicenseKey = textInput;
            break;
		case SETTINGS_SDK_SEGMENTS: {
			NSArray *updatedSegments = [textInput componentsSeparatedByString:@","];

			// trim whitespace from ends
			NSMutableArray *trimmedSegments = [NSMutableArray new];
			for (NSString *seg in updatedSegments) {
				NSString *trimmedSeg = [seg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				[trimmedSegments addObject:trimmedSeg];
			}
			updatedSegments = [trimmedSegments copy];

			// save to settings for next registration
			self.sharedSettings.userSegments = updatedSegments;

			// update SDK right now
			if (appDelegate().akaService.state != VOCServiceStateNotRegistered) {
				[appDelegate().akaService subscribeSegments:[NSSet setWithArray:updatedSegments]];
			}
			
		} break;
        case SETTINGS_WEB_URL:
            self.sharedSettings.webURL = textInput;
            break;
        default:
            break;
    }
}


@end
