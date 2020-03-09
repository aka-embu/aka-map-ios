/*!
   @header VocSdkBase.h

   @brief Header file that defines the common parts that relate to all aspects of the SDK.

   @copyright (c)2015,2016,2017 Akamai Technologies, Inc. All Rights Reserved. Reproduction in whole or in part in any form or medium without express written permission is prohibited.
 */


#ifndef VocSdk_VocSdkBase_h
#define VocSdk_VocSdkBase_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#if !defined(VOCSDK_EXPORT)

	#if defined(__cplusplus)
		#define VOCSDK_EXPORT	extern "C"
	#else
		#define VOCSDK_EXPORT	extern
	#endif

#endif

#pragma mark -- Version --
/*!
   @brief Voc SDK major build number constant.
 */
VOCSDK_EXPORT const int VocSdkVersionMajor;

/*!
   @brief Voc SDK minor build number constant.
 */
VOCSDK_EXPORT const int VocSdkVersionMinor;

/*!
   @brief Voc SDK release build number constant.
 */
VOCSDK_EXPORT const int VocSdkVersionBuild;

/*!
   @brief Voc SDK build number string constant.
 */
VOCSDK_EXPORT const unsigned char VocSdkVersionString[];



#pragma mark -- Logging --
/*!
   @enum LOG_LEVEL
   @brief A list of log level customer can set.

   @constant VOCSDK_DIAG_LOG_LEVEL_NONE Prints nothing.
   @constant VOCSDK_DIAG_LOG_LEVEL_LOW Prints Errors.
   @constant VOCSDK_DIAG_LOG_LEVEL_HIGH Prints Errors and Warnings.
 */
enum : int
{
	VOCSDK_DIAG_LOG_LEVEL_NONE			= 0,
	VOCSDK_DIAG_LOG_LEVEL_LOW			= 5,
	VOCSDK_DIAG_LOG_LEVEL_HIGH			= 10
};

/*!
   @brief Get the current diagnostic logging level.

   @return int Returns the current diagnostic logging level.
 */
VOCSDK_EXPORT int vocsdk_diag_get_log_level(void);

/*!
   @brief Controls the verbosity of the diagnostic messages in the console that VOC SDK will print.

   @discussion Log levels are defined in LOG_LEVEL enum.
 */
VOCSDK_EXPORT void vocsdk_diag_set_log_level(int level);


#pragma mark -- Policy Status --
/*!
   @brief Download Policy Status enumeration.

   @constant VOCPolicyStatusInPolicy SDK meets all the policies and can download.
   @constant VOCPolicyStatusNotRegistered SDK is not registered and cannot download.
   @constant VOCPolicyStatusNoDownload Policy does not allow SDK to download.
   @constant VOCPolicyStatusWifiNotAllowed Policy disallows SDK to download when in wifi.
   @constant VOCPolicyStatusHostUnreachableViaWifi Host is unreachable via wifi.
   @constant VOCPolicyStatusCellularNotAllowed Network policy disallows SDK to use cellular network for download.
   @constant VOCPolicyStatusHostUnreachableViaCellular Host is unreachable via cellular.
 */
typedef NS_OPTIONS(NSInteger, VOCPolicyStatus) {
	VOCPolicyStatusInPolicy						= 0,
	VOCPolicyStatusNotRegistered				= 1,
	VOCPolicyStatusNoDownload					= 2,
	//VOCPolicyStatusWifiDisallowedOnBattery		= 4,
	VOCPolicyStatusWifiNotAllowed				= 8,
	VOCPolicyStatusHostUnreachableViaWifi		= 0x10,
	//VOCPolicyStatusCellularDisallowedOnBattery	= 0x20,
	//VOCPolicyStatusCellularTimeOfDay			= 0x40,
	VOCPolicyStatusCellularNotAllowed			= 0x80,
	VOCPolicyStatusHostUnreachableViaCellular	= 0x100,
	//VOCPolicyStatusBatteryTooLow				= 0x200,
};

#pragma mark -- States --
/*!
   @brief Voc service states enumeration.

   @constant VOCServiceStateNotRegistered VocService is not registered. This is the initial state.
   @constant VOCServiceStateInitializing VocService is initializing. This is a transient state when service is starting up and still initializing, after that it will transtion to one of the other states.
   @constant VOCServiceStateIdle VocService is registered and initialized and is not downloading at the moment.
   @constant VOCServiceStateIdle VOCServiceStateIdle VocService is registered and initialized and is actively downloading at the moment.

   @see VocService
 */
typedef NS_ENUM(NSInteger, VOCServiceState) {
	VOCServiceStateNotRegistered		= 0,
	VOCServiceStateInitializing			= 1,
	VOCServiceStateIdle					= 2,
	VOCServiceStateDownloading			= 3
};

/*!
   @brief Item states enumeration.
   @constant VOCItemDiscovered IItem metadata has been received. Various device policies dictate whether the item gets queued for download.
   @constant VOCItemQueued Item has been added to downloading queue, it is currently not downloading. It will start downloading.
   @constant VOCItemDownloading Item is being downloaded.
   @constant VOCItemIdle Item is currently not downloading. Item has been previously queued for downloading but did not finish. Download will resume automatically at some point. Reason for stopping download can be found in VocItem::downloadError .
   @constant VOCItemCached Item download was completed successfully. Cached content is ready for use.
   @constant VOCItemFailed If MAP SDK is unsuccessful in downloading any file after a number of attempts, the item will be marked as failed and the downloaded content will be removed. No more download attempts will be made on the item, unless an explicit download for this item is triggered again. VocItem::downloadError can be used to verify the reason for download failure.
   @constant VOCItemDeleted Item has been deleted and cannot be used any more. There are no cached files.
   @see VocService
 */
typedef NS_ENUM(NSInteger, VOCItemState) {
	VOCItemDiscovered					= 0,
	VOCItemQueued						= 5,
	VOCItemDownloading					= 1,
	VOCItemIdle							= 6,
	VOCItemCached						= 2,
	VOCItemFailed						= 4,
	VOCItemDeleted						= 3,

	//deprecated mixed case aliases
	VocItemQueued = VOCItemQueued,
	VocItemIdle = VOCItemIdle,
	VocItemFailed = VOCItemFailed,
};

/*!
   @brief File states enumeration.

   @constant VOCFileDiscovered File is not downloaded.
   @constant VOCFileDownloading File is being downloaded.
   @constant VOCFileCached File is downloaded.
   @constant VOCFileFailed File handling by SDK such as downloading, saving etc. has resulted into an error.
   @constant VOCFileNotCached File will not be downloaded due to configurations.
  @constant VOCFileIdle File is currently not downloading. File has been queued for downloading before but did not finish downloading. Download will resume automatically at some point.
 */
typedef NS_ENUM(NSInteger, VOCFileState) {
	VOCFileDiscovered			= 0,
	VOCFileDownloading			= 1,
	VOCFileCached				= 2,
	VOCFileFailed				= 4,
	VOCFileNotCached			= 5,
	VOCFileSkipDownload			= 6,
	VOCFileIdle					= 7
};


#pragma mark -- Types --

/*!
   @brief File type enumeration.

   @constant VOCUnknownFile The type of the file cannot be determined.
   @constant VOCMainFile main file is the one pointed by content item url, or one of the main file variants.
 */
typedef NS_ENUM(int16_t, VocFileType) {
	VOCUnknownFile						= -1,
	VOCMainFile							= 0,

	// deprecated
	VocUnknownFile						= VOCUnknownFile,
	VocMainFile							= VOCMainFile,
};

#pragma mark -- Config --
/*!
   @brief Item Download Behavior enumeration.

   @discussion The value set on VocItem::downloadBehavior will override VocConfig::itemDownloadBehavior.

   @constant VOCItemDownloadSdkBehavior VocItem::downloadBehavior means, this content item follows VocConfig::itemDownloadBehavior. VocConfig::itemDownloadBehavior should not have this value.
   @constant VOCItemDownloadFullAuto If VocItem::downloadBehavior is VOCItemDownloadFullAuto, SDK downloads all the files of the content item. If VocConfig::itemDownloadBehavior is VOCItemDownloadFullAuto, SDK downloads all the files of the content item that has VocItem::downloadBehavior as VOCItemDownloadSdkBehavior.
   @constant VOCItemDownloadNone If VocItem::downloadBehavior is VOCItemDownloadNone, SDK does not download any files associated with the content item. If VocConfig::itemDownloadBehavior is VOCItemDownloadNone, SDK does not download any files for the content item that has VocItem::downloadBehavior as VOCItemDownloadSdkBehavior.
 */
typedef NS_ENUM(NSInteger, VOCItemDownloadBehavior) {
	VOCItemDownloadSdkBehavior			= 0,
	VOCItemDownloadFullAuto				= 1,
	VOCItemDownloadThumbnailOnly		= 2, // unused
	VOCItemDownloadNone					= 3,
	VOCItemDownloadBehaviorCount
};

/*!
   @brief Current SDK network connection type enumeration.

   @constant VOCConnectionNone There is no network connection.
   @constant VOCConnectionIsCellular There is cellular network connection.
   @constant VOCConnectionIsWiFi There is WiFi network connection.
 */
typedef NS_ENUM(NSInteger, VOCConnectionType) {
	VOCConnectionNone,
	VOCConnectionIsCellular,
	VOCConnectionIsWiFi,
};

/*!
   @brief User's preferred network selection type.

   @constant VOCNetworkSelectionNone SDK should not use any network.
   @constant VOCNetworkSelectionWifiOnly SDK downloads content over Wifi network.
   @constant VOCNetworkSelectionCellularOnly SDK downloads content over Cellular network.
   @constant VOCNetworkSelectionWifiAndCellular SDK downloads content over Wifi network and if Wifi network is not available, SDK downloads content over Cellular network.
 */
typedef NS_ENUM(NSInteger, VOCNetworkSelection) {
	VOCNetworkSelectionInvalid		   = -1,//invalid selection from client end.
	VOCNetworkSelectionNone			   = 0,
	VOCNetworkSelectionWifiOnly        = 100,
	VOCNetworkSelectionWifiAndCellular = 101,
	VOCNetworkSelectionCellularOnly	   = 102,
};

/*!
   @enum DownloadQuota

   @brief Download quota enumeration.

   @constant VOCDownloadQuotaUnlimited The value for unlimited download quota.
 */
enum : int64_t {

	VOCDownloadQuotaUnlimited		= INT64_MAX
};

#pragma mark -- MAP --
/*!
   @brief Network Quality enumeration.
 
   @discussion Based on the threshold range that is given by the customer for each network type(say 2g, 3g, 4g etc), SDK calculates the network quality.

   @constant VocNetworkQualityPoor If the network quality is below the lower threshold value.
   @constant VocNetworkQualityGood If the network quality is between lower and higher threshold value.
   @constant VocNetworkQualityExcellent If the network quality is above higher threshold value.
   @constant VocNetworkQualityUnknown If the network quality cannot be determined by SDK.
   @constant VocNetworkQualityNotReady If SDK is not ready yet to determine the network quality.
 */
typedef NS_ENUM(NSInteger, VocNetworkQualityStatus) {
	VocNetworkQualityPoor       = 0,
	VocNetworkQualityGood       = 1,
	VocNetworkQualityExcellent  = 2,
	VocNetworkQualityUnknown    = -1,
	VocNetworkQualityNotReady   = -2,
};

#pragma mark -- Errors --
/*!
   @brief Domain for errors coming out of Voc SDK.
 */
VOCSDK_EXPORT NSString * const VOCSDKErrorDomain;

/*!
   @brief Voc service error codes.

   @constant VOCErrInvalidParam An invalid parameter is passed to a call to voc service.
   @constant VOCErrCreateService Creating VocService failed.
   @constant VOCErrAlreadyRegistered SDK is already registered or is in the process of registeration .
   @constant VOCErrNotRegistered SDK is not registered or was logged out, need to register.
   @constant VOCErrRegisterFailedBadCredentials SDK failed to register due to bad credentials.
   @constant VOCErrRegisterFailedOther SDK failed to register for some other reason than bad credentials, network connection might not be available.
   @constant VOCErrDb Database Error.
   @constant VOCErrServerApiError Server API Error.
   @constant VOCErrServerApiErrorUnauthorized Server request from SDK was responded with unauthorized access error.
   @constant VOCErrServerApiErrorRequestFailed Server request from SDK got failed.
   @constant VOCErrServerApiErrorResponseParse Client failed to parse the server response.
   @constant VOCErrServerApiErrorResponseData Server response data is having error.
   @constant VOCErrServerApiErrorNotAllowed The API is not allowed for the registered SDK type.
   @constant VocErrCancelled Operation cancelled internally or due to unknown issue.
   @constant VocErrUserCancelled Operation cancelled externally by the client. This could happen when API is called to pause a download, delete an item or to cancel all downloads.
   @constant VocErrTimeOut Operation was cancelled because it did not finish in the allocated time.
   @constant VocErrBackgroundTimeOver Operation was cancelled because background execution time finished.
   @constant VocErrDownloadOptimization Download operation not started or was cancelled in order to optimize downloads.
   @constant VOCErrDownloadAlreadyInProgress Download operation not started or was cancelled because there is another download operation in progress.
   @constant VOCErrDownloadOutOfPolicy Download operation not started or was cancelled because download policy does not allow downloads at the moment.
   @constant VOCErrDownloadNetworkCongested Download operation not started or was cancelled because network is congested.
   @constant VOCErrDownloadDailyLimit Download operation not started or was cancelled because daily download limit was reached.
   @constant VOCErrDownloadCacheLimit Download operation not started or was cancelled because cache limit was reached.
   @constant VocErrShuttingDown Operation was cancelled because voc service is shutting down.
   @constant VocErrCongestionCheckFailed Congestion check failed for unspecified reason.
   @constant VocErrItemDeletionFailed VocItem deletion failed.
   @constant VocErrItemNotFound VocItem not found either locally or in server.
   @constant VocErrDownloadedItemImportFailed VocItem Local file Import failed.
   @constant VocErrDownloadNetworkError Network is not available for download or the network policy restricts the download.
   @constant VocErrDownloadItemCorrupted VocItem download failed, SDK cannot parse and process item.
   @constant VocErrCongestionCheckFailed404 Congestion check failed because of 404 response.
   @constant VocErrRegistrationDelayed	Registration got cancelled because it is configured for delayed registration.
   @constant VocErrDownloadHttpError Download failed due to http errors other than VocErrTimeOut.
   @constant VOCErrContentIdDoesNotExistInServer Item requested for download does not have metadata available in PCD Server.
   @constant VocErrMaxConcurrentDownloadLimit Number of items downloading has reached VocConfig::maxConcurrentDownloads.
 */
typedef NS_ENUM(NSInteger, VOCSDKError) {
	VOCErrInvalidParam						= -1000,
	VOCErrCreateService						= -1001,
	VOCErrAlreadyRegistered					= -1002,
	VOCErrNotRegistered						= -1003,
	VOCErrRegisterFailedBadCredentials		= -1004,
	VOCErrRegisterFailedOther				= -1005,
	VOCErrDb								= -1006,
	VOCErrServerApiError					= -1010,
	VOCErrServerApiErrorUnauthorized		= -1011,
	VOCErrServerApiErrorRequestFailed		= -1012,
	VOCErrServerApiErrorResponseParse		= -1013,
	VOCErrServerApiErrorResponseData		= -1014,
	VOCErrServerApiErrorNotAllowed			= -1016,
	VocErrCancelled							= -3072,
	VocErrUserCancelled						= -1100,
	VocErrTimeOut							= -1101,
	VocErrBackgroundTimeOver				= -1102,
	VocErrDownloadOptimization				= -1103,
	VOCErrDownloadAlreadyInProgress			= -1104,
	VOCErrDownloadOutOfPolicy				= -1105,
	VOCErrDownloadNetworkCongested			= -1106,
	VOCErrDownloadDailyLimit				= -1107,
	VOCErrDownloadCacheLimit				= -1108,
	VocErrShuttingDown						= -1109,
	VocErrCongestionCheckFailed             = -1110,
	VocErrItemDeletionFailed				= -1111,
	VocErrItemNotFound						= -1112,
	VocErrDownloadedItemImportFailed		= -1113,
	VocErrDownloadNetworkError				= -1114,
	VocErrDownloadItemCorrupted				= -1115,
	VocErrCongestionCheckFailed404          = -1117,
	VocErrRegistrationDelayed				= -1118,
	VocErrDownloadHttpError					= -1119,
	VOCErrContentIdDoesNotExistInServer     = -1121,
	VocErrMaxConcurrentDownloadLimit 		= -1223,
	VOCErrCancelledIgnoringTask             = -1124
};

#if !defined(AKAMAP_DEPRECATED)

#define AKAMAP_DEPRECATED	__attribute__((deprecated))

#endif

#endif //VocSdk_VocSdkBase_h
