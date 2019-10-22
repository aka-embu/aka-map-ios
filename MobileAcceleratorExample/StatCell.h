//
//  StatCell.h
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 11/12/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *labelResourceName;
@property (nonatomic, strong) IBOutlet UILabel *labelNetwork;
@property (nonatomic, strong) IBOutlet UILabel *labelCached;
@property (nonatomic, strong) IBOutlet UILabel *labelConnectionType;
@property (nonatomic, strong) IBOutlet UILabel *labelTimeSaved;

@end
