//
//  MenuVC.m
//  MobileAcceleratorExample
//
//  Created by Brian Salomon on 1/27/16.
//  Copyright © 2016 Akamai. All rights reserved.
//

#import <AkaMap/AkaMap.h>

#import "MenuVC.h"
#import "AICVC.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "LogVC.h"
#import "StatCell.h"
#import "SiteStats.h"
#import "WebCell.h"

typedef enum {
	MenuRegister = 0,
	MenuConnection,
	MenuSessionGET,
	MenuSessionPOST,
	MenuWebView,
	MenuQuality,
	MenuAIC,
	MenuFillCache,
	MenuClearCache,
	MenuLog,
	MenuSettings,
	CountMenuOptions
} MenuOptions;

@interface MenuVC ()

@property (nonatomic, strong) NSString *selectedSiteName;
@property (nonatomic, strong) NSURL *selectedURL;

@property (nonatomic, strong) NSString *urlSampleConnection;
@property (nonatomic, strong) NSString *urlSampleSession;
@property (nonatomic, strong) NSString *urlSampleSessionPOST;

@property (nonatomic, strong) NSString *sessionType; // @"GET" or @"POST"

@property (nonatomic, strong) NSMutableArray *statsArray; // array of SiteStats

@property (nonatomic,strong) AppSettings *sharedSettings;

@end

@implementation MenuVC

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.automaticallyAdjustsScrollViewInsets = NO;

	self.sharedSettings = [AppSettings sharedInstance];

    NSString *photoURL = @"https://www.akamai.com/us/en/multimedia/images/callout/akamai-about-who-we-are.jpg?interpolation=lanczos-none&downsize=1680px:*&output-quality=85&akamai-feo=off";
    self.urlSampleConnection = photoURL;
    self.urlSampleSession = photoURL;

    // the following service accepts POST requests and returns a string stating the number of parameters. 
    self.urlSampleSessionPOST = @"http://posttestserver.com/post.php";

    [self resetStats];

	[appDelegate().akaService printCache];

	[appDelegate().akaService setDebugConsoleLog:YES];

	[appDelegate().akaService printCurrentConfiguration];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserverForName:registrationUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
		[self.menuTable reloadData];
	}];
}

-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:registrationUpdate object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Various tests

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // generate a new set of trial stats
    [appDelegate().akaService clearStats];

    if ([segue.identifier isEqualToString:@"menuWebSegue"]) {
        WebVC *webVC = (WebVC*)segue.destinationViewController;
        webVC.siteName = self.selectedSiteName;
        webVC.url = self.selectedURL;
        webVC.webDelegate = self;
    } else if ([segue.identifier isEqualToString:@"menuConnectionSegue"]) {
        URLConnectionVC *connectionVC = (URLConnectionVC*)segue.destinationViewController;
        connectionVC.siteName = self.selectedSiteName;
        connectionVC.url = self.selectedURL;
        connectionVC.connectionDelegate = self;
    } else if ([segue.identifier isEqualToString:@"menuSessionSegue"]) {
        URLSessionVC *sessionVC = (URLSessionVC*)segue.destinationViewController;
        sessionVC.sessionType = self.sessionType;
        sessionVC.siteName = self.selectedSiteName;
        sessionVC.url = self.selectedURL;
        sessionVC.sessionDelegate = self;
	} else if ([segue.identifier isEqualToString:@"menuAICSegue"]) {
		AICVC *aicVC = (AICVC*)segue.destinationViewController;
		aicVC.url = self.selectedURL;
    } else if ([segue.identifier isEqualToString:@"menuLogSegue"]) {
        LogVC *logVC = (LogVC*)segue.destinationViewController;
        logVC.stats = [self.statsArray copy];
    }
}

- (void)loadURLConnection
{
    self.selectedSiteName = @"NSURLConnection";
    self.selectedURL = [NSURL URLWithString:self.urlSampleConnection];
    [self performSegueWithIdentifier:@"menuConnectionSegue" sender:self];
}

- (void)loadURLSessionGET
{
    self.sessionType = @"GET";
    self.selectedSiteName = @"NSURLSession";
    self.selectedURL = [NSURL URLWithString:self.urlSampleSession];
    [self performSegueWithIdentifier:@"menuSessionSegue" sender:self];
}

- (void)loadURLSessionPOST
{
    self.sessionType = @"POST";
    self.selectedSiteName = @"NSURLSession POST";
    self.selectedURL = [NSURL URLWithString:self.urlSampleSessionPOST];
    [self performSegueWithIdentifier:@"menuSessionSegue" sender:self];
}

- (void)loadWebView
{
	self.selectedSiteName = [AppSettings sharedInstance].webURL;
	self.selectedURL = [NSURL URLWithString:[AppSettings sharedInstance].webURL];
	[self performSegueWithIdentifier:@"menuWebSegue" sender:self];
}

- (void)testQuality
{
	if (appDelegate().akaService.state == VOCServiceStateNotRegistered) {
		[self flashMessage:nil withTitle:@"User Unregistered"];
		return;
	}

	id<VocNetworkQuality> networkQuality = appDelegate().akaService.networkQuality;
	switch([networkQuality qualityStatus]) {
        case VocNetworkQualityPoor:
            [self flashMessage:nil withTitle:@"Network Quality: Poor"];
            // Exit download
            break;
        case VocNetworkQualityGood:
            [self flashMessage:nil withTitle:@"Network Quality: Good"];
            // Throttle download
            break;
        case VocNetworkQualityExcellent:
            [self flashMessage:nil withTitle:@"Network Quality: Excellent"];
            // Download content
            break;
        case VocNetworkQualityUnknown:
            [self flashMessage:nil withTitle:@"Network Quality: Unknown"];
            break;
		case VocNetworkQualityNotReady:
			[self flashMessage:nil withTitle:@"Network Quality: Not Ready"];
			break;
	}
}

- (void) loadAICTest
{
	self.selectedURL = [NSURL URLWithString:@"http://cdnakashopify.test.edgekey-staging.net/s/files/1/1041/4212/products/p5img1.jpg"];
	[self performSegueWithIdentifier:@"menuAICSegue" sender:self];
}

- (void) flashMessage:(NSString *)message withTitle:(NSString*)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];

	// activate run loop to draw right away
	CFRunLoopWakeUp(CFRunLoopGetCurrent());
}

#pragma mark Cache Handling

- (void)fillCache
{
	if (appDelegate().akaService.state == VOCServiceStateNotRegistered) {
		[self flashMessage:nil withTitle:@"User Unregistered"];
		return;
	}

	[appDelegate().akaService startDownloadUserInitiatedWithCompletion:^(NSError *error){
        [self flashMessage:@"Began fill." withTitle:@"Cache Fill"];
    }];
}

// Clear database but maintain stats for comparison
- (void)eraseCache
{
	if (appDelegate().akaService.state == VOCServiceStateNotRegistered) {
		[self flashMessage:nil withTitle:@"User Unregistered"];
		return;
	}

    self.selectedSiteName = nil;
    self.selectedURL = nil;

    [appDelegate().akaService clearCache:^(NSError * __nullable error) {
        [self flashMessage:nil withTitle:@"Emptied Cache"];
    }];
}

#pragma mark SDK service handling

- (void) tappedConnect
{
	if (appDelegate().akaService.state != VOCServiceStateNotRegistered) {
		[self unregister];
	}
}

- (void)unregister
{
    [appDelegate().akaService unregisterService:^(NSError *error) {
        [self flashMessage:@"SDK is now inactive" withTitle:@"Unregistered!"];
		[self.menuTable reloadData];
    }];
}

#pragma mark Site statistics


- (void) resetStats
{
    self.statsArray = [[NSMutableArray alloc] init];
}

- (void) addStatsEntryForSiteName:(NSString*)siteName
{
    id<AkaMapProtocol> akaService = appDelegate().akaService;
    SiteStats *currentPageStats = [[SiteStats alloc] init];
    currentPageStats.resourceName = siteName;
    currentPageStats.connectionType = [akaService statsConnectionType];
    currentPageStats.loadTimeFromCache = @([akaService timeLoadingFromCache]);
    currentPageStats.loadTimeFromNetwork = @([akaService timeLoadingFromNetwork]);
    currentPageStats.dlFiles = @([akaService filesDownloaded]);
    currentPageStats.dlBytes = @([akaService bytesDownloaded]);
    currentPageStats.cacheFiles = @([akaService filesLoadedFromCache]);
    currentPageStats.cacheBytes = @([akaService bytesLoadedFromCache]);
    currentPageStats.skippedFiles = @([akaService filesNotHandled]);
    [self.statsArray addObject:currentPageStats];
}

#pragma mark WebVCDelegate

- (void) loadedWebSiteName:(NSString*)siteName
{
    [self addStatsEntryForSiteName:siteName];
}

#pragma mark ConnectionVCDelegate

- (void) loadedConnectionSiteName:(NSString*)siteName
{
    [self addStatsEntryForSiteName:siteName];
}

#pragma mark SessionVCDelegate

- (void) loadedSessionSiteName:(NSString*)siteName
{
    [self addStatsEntryForSiteName:siteName];
}



#pragma mark UITableViewDataSource delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return CountMenuOptions;
}

#pragma mark UITableViewDelegate delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.userInteractionEnabled = YES;
	cell.textLabel.enabled = YES;

	switch (indexPath.row) {
		case MenuRegister:
			if (appDelegate().akaService.state == VOCServiceStateNotRegistered) {
				cell.textLabel.text = @"<SDK is not running>";
				cell.textLabel.enabled = NO;
				cell.userInteractionEnabled = NO;
			} else {
				cell.textLabel.text = @"Unregister (SDK is running)";
			}
			break;
		case MenuConnection:
			cell.textLabel.text = @"NSURLConnection Demo";
			break;
		case MenuSessionGET:
			cell.textLabel.text = @"NSURLSession (GET) Demo";
			break;
		case MenuSessionPOST:
			cell.textLabel.text = @"NSURLSession (POST) Demo";
			break;
		case MenuWebView:
			cell.textLabel.text = @"UIWebView Demo";
			break;
		case MenuQuality:
			cell.textLabel.text = @"Network Quality Test";
			break;
		case MenuAIC:
			cell.textLabel.text = @"AIC Test";
			break;
		case MenuFillCache:
			cell.textLabel.text = @"Fill Cache";
			break;
		case MenuClearCache:
			cell.textLabel.text = @"Clear Cache";
			break;
		case MenuLog:
			cell.textLabel.text = @"Show Logs";
			break;
		case MenuSettings:
			cell.textLabel.text = @"Settings";
			break;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row) {
		case MenuRegister:
			[self tappedConnect];
			break;
		case MenuConnection:
			[self loadURLConnection];
			break;
		case MenuSessionGET:
			[self loadURLSessionGET];
			break;
		case MenuSessionPOST:
			[self loadURLSessionPOST];
			break;
		case MenuWebView:
			[self loadWebView];
			break;
		case MenuQuality:
			[self testQuality];
			break;
		case MenuAIC:
			[self loadAICTest];
			break;
		case MenuFillCache:
			[self fillCache];
			break;
		case MenuClearCache:
			[self eraseCache];
			break;
		case MenuLog:
			[self performSegueWithIdentifier:@"menuLogSegue" sender:self];
			break;
		case MenuSettings:
			[self performSegueWithIdentifier:@"menuSettingsSegue" sender:self];
			break;
	}
}


@end
