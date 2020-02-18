//
//  AkaCachedFile.h
//  MAPSdk
//
//  Created by Brian Salomon on 11/27/19.
//  Copyright © 2019 Akamai Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AkaCachedFile : NSObject

/*!
 * @brief URL of cached file.
 */
@property (nonatomic, strong) NSString *urlString;

/*!
 * @brief Cached headers from the content server at time of last refresh.
 */
@property (nonatomic, strong) NSDictionary<NSString*,NSString*> *responseHeaders;

/*!
 * @brief MIME type of cached file or nil if undetermined.
 * @discussion Usually derived from the server response's Content-Type header.
 * If unstated in the header, it may be inferred.
 */
@property (nonatomic, strong) NSString *inferredMIMEType;

/*!
* Path in application sandbox from which to load the body data.
*/
@property (nonatomic, strong) NSString *localPath;

@end

NS_ASSUME_NONNULL_END
