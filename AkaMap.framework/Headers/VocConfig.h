/*!
   @header VocConfig.h

   @brief Header file where SDK configurations are handled.

   @copyright (c)2015,2016,2017 Akamai Technologies, Inc. All Rights Reserved. Reproduction in whole or in part in any form or medium without express written permission is prohibited.
 */

#ifndef VocSdk_VocConfig_h
#define VocSdk_VocConfig_h

#import <AkaMap/VocSdkBase.h>


/*!
   @protocol VocConfig

   @brief Voc service configuration.
 */
@protocol VocConfig <NSObject>

/*! @brief The license provided through configuration or registration API. */
@property (readonly,nullable,atomic,strong)	NSString				*license;

/*!
   @brief Serverhost is the one that manages the content on the device.

   @discussion This configuration holds the effective setting for voc server. It returns serverHostOverride if set, else it returns serverHostFromLookup.
 */
@property (readonly,nonnull,nonatomic)		NSURL					*serverHost;

/*!
   @brief Setting for voc server that overrides the value from lookup.

   @discussion It is usually nil but during testing can be used to point to dev/qa servers.
 */
@property (readwrite,nullable,atomic)		NSURL					*serverHostOverride;

/*! @brief The voc server setting obtained from voc lookup. */
@property (readonly,nonnull,atomic,strong)	NSURL					*serverHostFromLookup;

/*!
   @brief Files larger than this value will not be downloaded.

   @discussion Default value is 104 MB.
 */
@property (readwrite,assign,atomic)			int64_t					fileSizeMax;

/*!
   @brief Access this configuration to know if downloads happen on wifi only, wifi and cellular or can be disabled all together.
   @discussion Default value is VOCNetworkSelectionWifiAndCellular and server configuration could override it.
 */
@property (readonly,assign,nonatomic)		VOCNetworkSelection		networkSelection;

/*!
 @brief Allows client to controls if download needs to happen on wifi only, wifi and cellular or can be disabled all together.
 @discussion Default value is VOCNetworkSelectionInvalid and it is a value used internally. SDK discourages client to set VOCNetworkSelectionInvalid value.
 */
@property (readwrite,assign,nonatomic)		VOCNetworkSelection		networkSelectionOverride;

/*!
 @brief Access this configuration to know what is the server network preference for download.
 */
@property (readonly,assign,nonatomic)		VOCNetworkSelection		networkSelectionDefault;

/*!
   @brief Daily wifi quota.

   @discussion VOCDownloadQuotaUnlimited for no limit. The default is unlimited and server configuration could override it.
 */
@property (readonly,assign,atomic)			int64_t					dailyWifiQuota;

/*!
   @brief Daily cellular quota.

   @discussion VOCDownloadQuotaUnlimited for no limit. The default is unlimited and server configuration could override it.
 */
@property (readonly,assign,atomic)			int64_t					dailyCellularQuota;

/*!
   @brief Daily wifi data used.

   @discussion Resets to 0 at 00:00.
 */
@property (readonly,assign,atomic)			int64_t					dailyWifiUsed;

/*!
   @brief Daily cellular data used.

   @discussion Resets to 0 at 00:00.
 */
@property (readonly,assign,atomic)			int64_t					dailyCellularUsed;

/*! @brief The sum of dailyWifiUsed and dailyCellularUsed. */
@property (readonly,assign,atomic)			int64_t					dailyDownloadUsed;

/*!
   @brief This configuration will drive the download behavior of sdk provided the item download behavior is set to VOCItemDownloadSdkBehavior.

   @discussion The default behavior is to download all files associated with the item automatically. An individual item can override this behavior. See VocItem::downloadBehavior. VOCItemDownloadSdkBehavior is an invalid value for this config.
 */
@property (readwrite,assign,nonatomic)		VOCItemDownloadBehavior	itemDownloadBehavior;

/*!
   @brief If YES, triggers SDK purge mechanism when needed.

   @discussion By default MAP service automatically manages the cache. It removes old content from the DB and its associated files from the cache folder. This can be disabled and managed by the SDK customer by setting this property to NO.
 */
@property (readwrite,assign,nonatomic)		BOOL					enableAutoPurge;

/*!
   @brief Limits the number of concurrent downloads, -1 no limit.

   @discussion Default value is -1.
 */
@property (readwrite,assign, nonatomic)		int						maxConcurrentDownloads;

/*!
   @brief If set as NO, VocService::bytesDownloaded won't be updated.

   @discussion During download bytesDownloaded is updated every time a chunk of data is downloaded.However sometimes if download is interrupted it cannot be resumed and bytesDownloaded will reset to 0. This might not be desired behavior and can be changed by setting this property to NO. When this property is set to NO bytesDownloaded is not updated until after the file is fully downloaded. Default value is YES.
 */
@property (readwrite,assign,nonatomic)		BOOL					trackFileDownloadProgress;

/*!
 @brief if Yes, user download request will start immediately and does not respect device policies.

 @discussion Default value is NO.
 */
@property (readwrite,assign,nonatomic)		BOOL					forceDownload;

/*!
 @brief Seconds after coming to foreground to delay a check for new content.

 @discussion This delay helps reduce interference with time-critical tasks such as UI setup.  Default value is 3.0 seconds.
 */
@property (readwrite,assign,nonatomic)		NSTimeInterval			foregroundContentCheckDelay;

/*!
 @brief Tell URL interceptor to automatically follow HTTP/S redirects.
 Set YES to follow redirects and return the final response to your app.
 Set NO to return the 30x response to your app.

 @discussion Defaults to YES.
 */
@property (readwrite,assign,nonatomic)		BOOL					autoFollowRedirects;

/*!
 @brief Set a list of HTTP methods to be ignored by the SDK.  These will be rejected
 by the SDK's NSURLProtocol handler and will pass to the next handler in line.
 This may be your own handler or the default system handler.

 @discussion Defaults to ["OPTIONS"].  Set nil to tell the SDK to handle all HTTP methods.
 Case and sequence in array do not matter.
 */
@property (readwrite,strong,nonatomic,nullable) NSArray<NSString*>	*ignoredHTTPMethods;


/*!
 @brief if Yes, add SDK generated user agent to all requests.
 Ex. Mozilla/5.0 (iPhone; CPU iPhone OS 11_2 like Mac OS X) AppleWebKit/604.4.7 (KHTML, like Gecko) Mobile/15C107

 @discussion Default value is NO.
 */
@property (readwrite,assign,nonatomic)		BOOL					addUserAgent;

/*!
 @brief This method will whitelist a list of host names

 @discussion All host names other than the whitelisted host names will not be processed by the SDK.
 Calling this method will clear the blacklisted host names.
 If array is set multiple times, white listed host names will be overwritten.
 @param whitelist An array of whitelisted host name strings.
 Passing a nil whitelist array would reset all filtering.

 Ex. [akaService.config setWhitelist:@[@"www.xyz.com"]];
 */
- (void)setWhitelist:(nullable NSArray<NSString*> *)whitelist;

/*!
 @brief This method will blacklist a list of host names

 @discussion The blacklisted host names will not be processed by the SDK.
 Calling this method will clear the whitelisted host names.
 If array is set multiple times, black listed host names will be overwritten.
 @param blacklist An array of blacklisted host name strings.
 Passing an empty or nil blacklist array would reset all filtering.

 Ex. [akaService.config setBlacklist:@[@"www.xyz.com"]];
 */
- (void)setBlacklist:(nullable NSArray<NSString*> *)blacklist;

@end

#endif
