/*!
 @header VocService.h

 @brief Header file where SDK registration, service initialization and other primary SDK functionalies are defined.

 @copyright (c)2015-2019 Akamai Technologies, Inc. All Rights Reserved. Reproduction in whole or in part in any form or medium without express written permission is prohibited.
*/


#ifndef VocSdk_VocService_h
#define VocSdk_VocService_h

#import <AkaCommon/AkaConfigurable.h>
#import <AkaMap/VocSdkBase.h>
#import <AkaMap/AkaCachedFile.h>

@protocol VocConfig;
@protocol VocNetworkQuality;
@protocol VocService;
@protocol VocServiceDelegate;
@protocol AkaMapProtocol;

/*!
   @interface AkaMap
   @brief Factory for VocService.
   @discussion AkaMap is used to access the main SDK instance.  For instance usage, see VocService.
   @see VocService
 */
@interface AkaMap : NSObject

/*! @brief init is disabled for AkaMap. Use +sharedInstance. */
- (nonnull instancetype)init NS_UNAVAILABLE;

@end


/*!
   @protocol VocService

   @brief VocService encapsulates the functionality provided by Voc SDK.

   @discussion The VocService instance is created through AkaMap.
   To create the service, a delegate implementing VocServiceDelegate protocol and delegate queue are required. In most cases the
	delegate queue will be the main app queue, however there is no restriction what type of queue to use. If the queue is not serial then
	users of MAP SDK must ensure MAP item objects are accessed serially since they are not thread safe. One such way to achieve
	that would be to add a lock object of some kind on MAP item userInfo and use it to serialize access.

   VocService state is available through VocService.state property. Initially VocService is in VOCServiceStateNotRegistered state until it
	is successfully registered with MAP server. To register, call [VocService registerService].

   @see AkaMap
 */
@protocol VocService <NSObject>


/*! @brief The current state of voc service. */
@property (readonly,assign,nonatomic)			VOCServiceState		state;

/*! @brief Provides access to various configations properties of voc service. */
@property (readonly,nonnull,strong,nonatomic)	id<VocConfig>		config;

/*! @brief Gives the current network connection type and if there is one at all. */
@property (readonly,assign,nonatomic)			VOCConnectionType	connectionType;

/*! @brief Shows if voc service policies allow downloads at the moment. */
@property (readonly,assign,nonatomic)			BOOL				downloadAllowed;

/*! @brief Access the last policy status of voc service. */
@property (readonly, assign, nonatomic)			VOCPolicyStatus		lastPolicyStatus;

#pragma mark -- registration --

/*!
   @brief Unregisters voc service with Voc server and stops downloading.
 */
- (void)unregisterService:(nullable void (^)(NSError * __nullable))completion;


#pragma mark -- cache --
/*! @brief Size of the cache for downloaded files (bytes). */
@property (readwrite,assign,nonatomic)  uint64_t cacheSize;

/*! @brief The amount of storage used for downloaded files (bytes). */
@property (readonly,assign,nonatomic)   uint64_t cacheUsed;

/*! @brief The remaining storage available for downloaded files (bytes). This is the smaller values of the unused cache and the
	space available on device. */
@property (readonly,assign,nonatomic)   uint64_t cacheAvailable;


#pragma mark -- UIApplicationDelegate --

/*!
   @brief Must be invoked when remote notification is received to let Voc SDK process it.

   @param completionHandler will be called only if the remote notification was for the MAP service
 	(the method returned YES). Sometimes it might be called before this method returns. If this
 	method returns NO the app will have to call the completionHandler received from iOS.
   @param userInfo This is obtained from UIApplicationDelegate::didReceiveRemoteNotification:fetchCompletionHandler:
 	and passed into this method. It is a dictionary that contains information related to the remote
 	notification, potentially including a badge number for the app icon, an alert sound, an alert message to display to the user, a
	notification identifier, and custom data.

   @return Will return YES if the remote notification is for voc service, otherwise NO.
 */
- (BOOL)didReceiveRemoteNotification:(nullable NSDictionary *)userInfo
			  fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult result))completionHandler;

/*!
   @brief Must be invoked when OS wakes up app in background to perform fetch.

    @param application Singleton app object.
    @param completionHandler Gets called if voc service performs operation in the background otherwise completionHandler will
	not be called by voc service - the app will have to call it when it is done. If the app wants to perform operations in background it will
	have to give voc service a different completionHandler not the one it received. The app should call the original completionHandler
	only after both it is done and the compeltionHandler it gave to voc service is invoked.

   @return Will return YES if voc service performs operations in background.
 */
- (BOOL)application:(nonnull UIApplication *)application
performFetchWithCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult result))completionHandler;


#pragma mark -- others --

/*! @brief List of SDK log files. */
@property (readonly,nullable,strong,atomic) NSArray *sortedLogFilePaths;

/*!
   @brief Gets the current network quality.
 */
- (nullable id<VocNetworkQuality>)networkQuality;


#pragma  mark -- Deprecated --

- (void)registerWithLicense:(nonnull NSString *)sdkLicense
				   segments:(nullable NSArray *)segments
				 completion:(nullable void (^)(NSError * __nullable))completion AKAMAP_DEPRECATED;

- (void)startDownloadUserInitiatedWithCompletion:(nullable void (^)(NSError * __nullable))completion AKAMAP_DEPRECATED;

- (void)clearCache:(nullable void (^)(NSError * __nullable))completion AKAMAP_DEPRECATED;

@end


/*!
   @protocol VocServiceDelegate

   @brief Interface for VocService delegate.

   @discussion VocServiceDelegate provides various methods to notify of various changes in VocService. All method calls happen on
	delegate queue.

   @see VocService
 */
@protocol VocServiceDelegate <NSObject>

@optional

/*!
   @brief Invoked when VocService transitions to not registered state.

   @discussion This is not called initially when the service is started in an unregistered state. When the service is in registered state it
	may be notified by MAP server that the account is no longer valid and then MAP Service will transition to unregistered state and
	invoke this method.

   @see VocService

   @deprecated The registered state has been removed.
 */
- (void)vocService:(nonnull id<VocService>)vocService
didBecomeNotRegistered:(nonnull NSDictionary *)info AKAMAP_DEPRECATED;


/*!
   @brief Invoked when VocService registerWithLicense: is called and registering fails.

   @discussion Registration can fail for various reasons, like not network or bad license, etc. When this happens the completion
	passed in registerWithLicense: will be called and after that this delegate method will be called.

   @param vocService An instance of VocService.
   @param error Error details for registration failure.

   @see VocService

   @deprecated The registered state has been removed.
 */
- (void)vocService:(nonnull id<VocService>)vocService
 didFailToRegister:(nonnull NSError *)error AKAMAP_DEPRECATED;


/*!
   @brief Invoked when VocService registerWithLicense: is called and registration succeeds.

   @discussion When registration succeeds the completion passed in registerWithLicense: will be called and after that this delegate
	method will be called.

   @param vocService An instance of VocService.
   @param info More information on successful registration.

   @see VocService

   @deprecated The registered state has been removed.
 */
- (void)vocService:(nonnull id<VocService>)vocService
	   didRegister:(nonnull NSDictionary *)info AKAMAP_DEPRECATED;


/*!
   @brief Invoked when VocService has finished initialization.

   @discussion This delegate method will be called when the VocService has finished initialization. This indicates the SDK is ready
	for processing requests.

   @param vocService An instance of VocService.
   @param info More information on successful registration.

   @see VocService

   @deprecated The SDK manages state internally.
 */
- (void)vocService:(nonnull id<VocService>)vocService
	 didInitialize:(nonnull NSDictionary *)info AKAMAP_DEPRECATED;

/*!
   @brief Invoked when MAP SDK receives a server trust challenge.

   @discussion This optional method allows the app to approve or disallow connections when posed a server trust challenge.
	If this callback is not implemented, the SDK will perform default trust handling (i.e., using trusted authorities on the device).

   @note This may be called multiple times for a single URL request in the case of multipath HTTP/SR4C.
   @note 'modifiedTrust' is released at the end of this call. To use it beyond this method call, it must be retained and released when
	done.

    @param originalRequest The request made by your app. Its hostname should match the 'modifiedTrust'.
    @param currentRequest A modified request made by the SDK. This may have its hostname resolved to an IP address.
	@param challenge The server trust challenge. The protectionSpace hostname and serverTrust object may have their hostnames
	resolved to an IP address. For this reason, use 'modifiedTrust' when performing trust checks instead of
	'challenge.protectionSpace.serverTrust'.
	@param modifiedTrust A copy of 'challenge.protectionSpace.serverTrust' using the server's hostname instead of its IP address.
	This is the correct trust object to use for server trust checks, pinned certificate comparisons, etc.
	@param completion A block indicating whether the SDK should proceed with or cancel the request. Its parameters follow the
	same rules as NSURLSession::didReceiveChallenge.
 */
- (void)vocService:(nonnull id<VocService>)vocService
didReceiveChallengeForRequest:(nonnull NSURLRequest *)originalRequest
	currentRequest:(nonnull NSURLRequest *)currentRequest
		 challenge:(nonnull NSURLAuthenticationChallenge *)challenge
	 modifiedTrust:(nullable SecTrustRef)modifiedTrust
		completion:(nonnull void (^)(NSURLSessionAuthChallengeDisposition disposition,
									 NSURLCredential * _Nullable credential))completion;

/*!
   @brief This method will be invoked to signal a change in network quality.

   @discussion This method will receive the results of the latest network quality check.

   @param vocService An instance of VocService.
   @param networkQuality An instance of VocNetworkQuality.
 */
- (void)vocService:(nonnull id<VocService>)vocService
networkQualityUpdate:(nonnull id<VocNetworkQuality>)networkQuality;

/*!
 @brief Update delegate with changes to the SDK's cached files.
 */
- (void)cacheAdded:(nullable NSSet<AkaCachedFile*> *)added
		   updated:(nullable NSSet<AkaCachedFile*> *)updated
		   removed:(nullable NSSet<AkaCachedFile*> *)removed;

@end


/*!
   @protocol VocNetworkQuality

   @brief Interface for network quality

   @discussion VocNetworkQuality encapsulates the network quality properties.

   @see VocService
 */
@protocol VocNetworkQuality <NSObject>

/*! @brief The latest network quality status. */
@property (readonly, assign, nonatomic) VocNetworkQualityStatus qualityStatus;

/*! @brief Time stamp of the latest network quality measurement. */
@property (readonly, nonnull, strong, nonatomic) NSDate *timeStamp;

@end

#endif
