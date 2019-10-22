//
//  LogVC.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 1/27/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableLogs;
@property (nonatomic, strong) NSArray *stats;

@end
