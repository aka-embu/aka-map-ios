//
//  URLConnectionVC.m
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 11/13/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import "URLConnectionVC.h"

@interface URLConnectionVC ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NSInteger responseStatusCode;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval loadTimeElapsed;

@end

@implementation URLConnectionVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.startTime = [NSDate timeIntervalSinceReferenceDate];

    // disable NSURLConnection cache to demonstrate SDK
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];

    // Demonstrate using deprecated NSURLConnection
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
#pragma GCC diagnostic pop

    if (! connection) {
        NSLog(@"Error creating NSURLConnection.");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// run on main thread only due to UIKit reference
- (void) updateImage
{
    self.image = [UIImage imageWithData:self.responseData];
    [self.imageView setImage:self.image];
}

#pragma mark NSURLConnection callbacks

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // called on response or redirect
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse) {
        self.responseStatusCode = httpResponse.statusCode;
    }

    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // return nil to disable the shared cache
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSTimeInterval timeNow = [NSDate timeIntervalSinceReferenceDate];
    self.loadTimeElapsed = timeNow - self.startTime;

    [self.connectionDelegate loadedConnectionSiteName:self.siteName];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateImage];

        self.statusLabel.text = [NSString stringWithFormat:@"Status Code: %ld\nSize: %ld bytes",
                                 (long)self.responseStatusCode, (unsigned long)self.responseData.length];
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"NSURLConnection Error: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = [error localizedDescription];
    });
}

@end
