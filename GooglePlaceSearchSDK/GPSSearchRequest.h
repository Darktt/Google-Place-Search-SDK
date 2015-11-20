//
//  GPSSearchRequest.h
//
//  Created by EdenLi on 2015/4/30.
//  Copyright (c) 2015年 Darktt. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, GPSErrorCode) {
    GPSErrorCodeOverQueryLimit = -1,
    GPSErrorCodeRequestDenied = -99,
    GPSErrorCodeInvaldRequest = -100
};

@class GPSSearchRequest;

typedef void (^GPSSearchResult) (GPSSearchRequest *request, NSArray *places, NSError *error);

@interface GPSSearchRequest : NSObject

/// The latitude/longitude around which to retrieve place information.
@property (assign) CLLocationCoordinate2D location;

/** Defines the distance (in meters) within which to bias place results.
 *  The maximum allowed radius is 50000 meters.
 */
@property (assign) NSUInteger radius;

/** The language for result, if possible.
 *  More information see: https://developers.google.com/maps/faq#languagesupport
 */
@property (retain, nonatomic) NSString *language;

/// Returns only those places that are open for business at the time the query is sent.
@property (assign) BOOL openNow;

/// Yes when result has next page.
@property (readonly) BOOL hasNextPage;

+ (instancetype)searchRequestWithQuery:(NSString *)query;
- (instancetype)initWithQuery:(NSString *)query;

/// Set locale, will set language via locale.
- (void)setLocale:(NSLocale *)locale;

/// Start query places.
- (void)startSearchWithCompletionHandler:(GPSSearchResult)handler;

/** Query next places, it will delay 2 second. \n
 * Will start query when self.hasNextPage is Yes, otherwise not.
 */
- (void)queryNextPage;

@end
