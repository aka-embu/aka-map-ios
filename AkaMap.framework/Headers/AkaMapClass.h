/*!
   @header AkaMapClass.h

   @brief Import this header file for accessing MAP SDK APIs.

   @copyright (c)2015-2019 Akamai Technologies, Inc. All Rights Reserved. Reproduction in whole or in part in any form or medium without express written permission is prohibited.
 */

#ifndef AkaMap_AkaMapClass_h
#define AkaMap_AkaMapClass_h

#import <AkaMap/VocSdkBase.h>
#import <AkaMap/VocService.h>
#import <AkaMap/AkaCachedFile.h>

@protocol AkaMapProtocol;
@class AkaMap;


/*!
   @category AkaMap (AkaMap)
   @brief A category of AkaMap with MAP SDK specific APIs.
   @see AkaMap
 */
@interface AkaMap (AkaMap)

+ (nonnull id<AkaMapProtocol>)shared;

/*!
   @brief Creates instance of web accelerator.

   @discussion This factory method creates instance of web accelerator. A delegate implementing VocServiceDelegate protocol and delegate queue are required. In most cases the delegate queue will be the main app queue, however there is no restriction what type of queue to use. If the queue is not serial then users of Voc SDK must ensure voc item objects are accessed serially since they are not thread safe.

   @param delegate The delegate for VocService.
   @param delegateQueue The queue on which the delegate calls will be invoked, item set delegate calls are also invoked on this queue.
   @param options (optional) The options to configure VocService.
   @param error This parameter has the error information if VocService instance cannot be created.
 */
+ (nullable id<AkaMapProtocol>)createAkaMapWithDelegate:(nonnull id<VocServiceDelegate>)delegate
										  delegateQueue:(nonnull NSOperationQueue *)delegateQueue
												options:(nullable NSDictionary *)options
												  error:(NSError * __nullable __autoreleasing * __nullable)error __deprecated_msg("Call AkaCommon +configure to create MAP.");

@end


/*!
   @protocol AkaMapProtocol.

   @brief AkaMapProtocol encapsulates the Mobile Accelerator functionality provided by MAP SDK.

   @see VocService
 */
@protocol AkaMapProtocol <VocService>

/*!
 @brief Replace the current callback handler.

 @discussion Designates a handler for MAP service callbacks. The previous handler
 is no longer notified.  Pass nil delegate and nil delegateQueue to stop receiving
 callbacks.

 @param delegate Your implementation of VocServiceDelegate.
 @param delegateQueue The queue on which to call your delegate.
 */
- (void)setDelegate:(nullable id<VocServiceDelegate>)delegate
 withOperationQueue:(nullable NSOperationQueue*)delegateQueue;

/*!
 @brief Return whether MAP SDK is initialized and URL interception is enabled.
 */
- (BOOL)enabled;

/*!
 @brief Replace list of user segments. Content is refreshed immediately.

 @discussion This immediately syncs with the server to get a current list of
 content for the subscribed segments. Unsubscribed items are deleted and new
 items begin downloading.

 Pass the complete list of segments for this user with every update. For example,
 the user is in ["A","B"] and you want to add "C". Subscribe to ["A","B","C"].
 Any segments not listed will be unjoined and their contents deleted.
 Contents contained in at least one subscribed segment is retained.

 @param segments A set of segment names to join or stay joined. An empty set
 will unsubscribe from all segments.
 */
- (void)subscribeSegments:(nonnull NSSet <NSString *> *)segments;

/*!
 @brief Returns set of content segments currently subscribed by the app.

 @discussion These segments were joined at initialization via Info.plist, or via
 the -subscribeSegments: call.  Segment contents are not necessarily downloaded yet.
 */
- (nullable NSSet <NSString *> *)subscribedSegments;

//Analytics
/*!
   @brief Creates a new record of an instantaneous event. Saves a string and time stamp to analytics.

   @param eventName Name of the event.
 */
- (void)logEvent:(nonnull NSString *)eventName;

/*!
   @brief Starts recording of a timed event for analytics.

   @discussion Pair with -stopEvent: to record a string, start time, and end time.

   @param eventName Name of the event.
 */
- (void)startEvent:(nonnull NSString *)eventName;

/*!
   @brief Stops recording of a timed event for analytics.

   @discussion Pair with -startEvent: to record a string, start time, and end time.

   @param eventName Name of the event.
 */
- (void)stopEvent:(nonnull NSString *)eventName;


// Developer Commands
/*!
   @brief Debug Only - Enable or disable the debug console.

   @param bDebugConsole If YES, enables extra information in the developer console.
 */
- (void)setDebugConsoleLog:(BOOL)bDebugConsole;

/*!
 @brief Debug Only - print contents of URL cache and subscribed URL segments.
 */
- (void)printCache;

//--------------------------------------
// WKWebView support

/*!
 @brief Return file paths to completed items in the cache.
 */
- (nonnull NSSet<AkaCachedFile*> *)cachedFiles;

/*!
 @brief Return file for URL if present in cache, otherwise nil.
 */
- (nullable AkaCachedFile*)cachedFileForURL:(nonnull NSString *)urlString;

//--------------------------------------

/*!
   @brief Debug Only - print manifest contents.
   @deprecated Renamed to match Android.
 */
- (void)printManifest __deprecated_msg("Use -printCache");

/*!
   @brief Debug Only - print current SDK configuration to the developer console.
 */
- (void)printCurrentConfiguration;

/*!
 @brief Debug Only - print current SDK capabilities to the developer console.
 @deprecated Renamed to match Android.
 */
- (void)printCurrentCapabilities __deprecated_msg("Use -printCurrentConfiguration");

/*!
   @brief Debug Only - send analytics to server now instead of waiting for regular cycle.
 */
- (void)debugSendAnalytics;

/*!
 @brief Changes an NSURLSessionConfiguration to pass requests through MAP SDK's URL handler.

 @param sessionConfig Instance of NSURLSessionConfiguration.

 @deprecated Switch to the updated [[AkaCommon shared] interceptSessionsWithConfiguration:sessionConfig];
 */
- (void)setupSessionConfiguration:(nonnull NSURLSessionConfiguration *)sessionConfig DEPRECATED_MSG_ATTRIBUTE("Replace with [[AkaCommon shared] interceptSessionsWithConfiguration:sessionConfig]");

//TODO: THESE APIS WILL BE REMOVED SOON. PLEASE DO NOT USE.
// Wrap AkaURLRequester class methods for sample app
- (NSTimeInterval)timeLoadingFromCache;
- (NSTimeInterval)timeLoadingFromNetwork;
- (NSInteger)filesDownloaded;
- (NSInteger)bytesDownloaded;
- (NSInteger)filesLoadedFromCache;
- (NSInteger)bytesLoadedFromCache;
- (NSInteger)filesNotHandled;
- (nonnull NSArray <NSString*>*)filesRequested;
- (nullable NSString *)statsConnectionType;
- (void)clearStats;

@end



#endif /* VocSdk_AkaMapClass_h */
