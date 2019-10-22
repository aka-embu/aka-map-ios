//
//  MenuVC.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 1/27/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLConnectionVC.h"
#import "URLSessionVC.h"
#import "WebVC.h"

@interface MenuVC : UIViewController <WebVCDelegate, ConnectionVCDelegate, SessionVCDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *menuTable;

@end

