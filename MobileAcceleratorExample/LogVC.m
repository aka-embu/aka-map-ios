//
//  LogVC.m
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 1/27/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import "LogVC.h"
#import "SiteStats.h"
#import "StatCell.h"

@interface LogVC ()

@end

@implementation LogVC

- (void)viewDidLoad {
    [super viewDidLoad];
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
    return self.stats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(indexPath.row < self.stats.count);

    SiteStats *stats = [self.stats objectAtIndex:indexPath.row];

    StatCell *cell = (StatCell*)[self.tableLogs dequeueReusableCellWithIdentifier:@"statCell"];

    cell.labelResourceName.text = stats.resourceName;

    double bytesCached = [stats.cacheBytes integerValue];
    double bytesDownloaded = [stats.dlBytes integerValue];

    double secondsFromCache = [stats.loadTimeFromCache doubleValue];
    double secondsFromNetwork = [stats.loadTimeFromNetwork doubleValue];

    cell.labelNetwork.text = [NSString stringWithFormat:@"Network: %ld requests, %ld bytes, %.0f ms",
                              (long)[stats.dlFiles integerValue], (long)[stats.dlBytes integerValue], secondsFromNetwork * 1000.0];
    cell.labelCached.text = [NSString stringWithFormat:@"Cached: %ld requests, %ld bytes, %.0f ms ",
                             (long)[stats.cacheFiles integerValue], (long)[stats.cacheBytes integerValue], secondsFromCache * 1000.0];
    cell.labelConnectionType.text = [NSString stringWithFormat:@"Type: %@", stats.connectionType];

    double secondsPerByteNetwork = (bytesDownloaded > 0) ? secondsFromNetwork/bytesDownloaded : 0;
    double secondsIfCacheDataWasNetworked = bytesCached * secondsPerByteNetwork;
    double timeSaved = secondsIfCacheDataWasNetworked;  // ideally time saved = secondsIfCacheDataWasNetworked (time it would have taken) - secondsFromCache (time actually taken)
    if (timeSaved < 0) {
        timeSaved = 0;
    }
    cell.labelTimeSaved.text = [NSString stringWithFormat:@"Saved: %.1f ms", timeSaved * 1000];

    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }

    return cell;
}

#pragma mark UITableViewDelegate


@end
