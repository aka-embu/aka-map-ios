//
//  WebVC.m
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 9/16/15.
//  Copyright © 2015 Akamai. All rights reserved.
//

#import "WebVC.h"

@interface WebVC ()

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval loadTimeElapsed;
@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation WebVC

- (void) viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.startTime = [NSDate timeIntervalSinceReferenceDate];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.url
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    [self.webView loadRequest:urlRequest];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if ([self.webView isLoading]) {
        [self.webView stopLoading];
    }
}

- (void) dealloc
{
    self.webView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) flashMessage:(NSString *)message withTitle:(NSString*)title
{
    if (self.alertController) {
        // alert already showing.  try again soon.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self flashMessage:message withTitle:title];
        });
        return;
    }

    if (! [self.view superview]) {
        NSLog(@"Left webview.  Skipping title: %@, message: %@", title, message);
        return;
    }

    self.alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGRect bounds = self.view.bounds;
        CGFloat bottomY = bounds.origin.y + bounds.size.height;
        bounds = CGRectMake(bounds.origin.x, bottomY, bounds.size.width, 0.0);
        self.alertController.popoverPresentationController.sourceRect = bounds;
        self.alertController.popoverPresentationController.sourceView = self.view;
    }

    [self presentViewController:self.alertController animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
                self.alertController = nil;
            }];
        });

    }];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // Note: we would like to clear network stats before each new page,
    //       but this is called several times (once per frame).
    //       Going beyond this demo, one could accumulate stats across
    //       frames and store those stats for each URL loaded.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSTimeInterval timeNow = [NSDate timeIntervalSinceReferenceDate];
    if (! webView.isLoading) {
        self.loadTimeElapsed = timeNow - self.startTime;

        [self flashMessage:self.url.absoluteString withTitle:[NSString stringWithFormat:@"%.2fs", self.loadTimeElapsed]];

        [self.webDelegate loadedWebSiteName:[webView.request.mainDocumentURL absoluteString]];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self flashMessage:@"Cannot load page" withTitle:@"Offline"];
}

@end
