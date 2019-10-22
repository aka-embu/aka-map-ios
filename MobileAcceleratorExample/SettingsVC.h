//
//  SettingsVC.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 2/2/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableSettings;

@end
