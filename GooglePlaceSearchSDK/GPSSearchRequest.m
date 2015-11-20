//
//  GPSSearchRequest.m
//
//  Created by EdenLi on 2015/4/30.
//  Copyright (c) 2015年 Darktt. All rights reserved.
//

#import "GPSSearchRequest.h"
#import "GPSServices.h"
#import "GPSPlaceItem.h"

#pragma mark - GPSServices Category

@interface GPSServices (Category)

@property (readonly) NSString *APIKey;

+ (instancetype)shareServices;

@end

#pragma mark - GPSPlaceItem Category

@interface GPSPlaceItem (Category)

+ (instancetype)placeItemWithDictionary:(NSDictionary *)dictionary;

@end

#pragma mark - GPSSearchRequest

#define TEXT_SEARCH 0

#if TEXT_SEARCH

NSString * const DefaultURL = @"https://maps.googleapis.com/maps/api/place/textsearch/json?";

#else

NSString * const DefaultURL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?";

#endif

@interface GPSSearchRequest ()
{
    NSString *_query;
    BOOL _isCoordinateChanged;
    
    GPSSearchResult _handler;
    
    // Will auto release, when have not next page.
    NSString *_nextPageToken;
}

@property (assign) BOOL hasNextPage;

@end

@implementation GPSSearchRequest

+ (instancetype)searchRequestWithQuery:(NSString *)query
{
    GPSSearchRequest *request = [[GPSSearchRequest alloc] initWithQuery:query];
    
    return [request autorelease];
}

- (instancetype)initWithQuery:(NSString *)query
{
    self = [super init];
    if (self == nil) return nil;
    
    _query = [[NSString alloc] initWithString:query];
    _isCoordinateChanged = NO;
    
    [self setRadius:50000];
    [self setOpenNow:YES];
    
    [self addObserver:self forKeyPath:@"location" options:NSKeyValueObservingOptionNew context:nil];
    
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"location"];
    
    [_query release];
    [_nextPageToken release];
    
    [self setLanguage:nil];
    
    Block_release(_handler);
    
    [super dealloc];
}

#pragma mark - Public Method

- (void)setLocale:(NSLocale *)locale
{
    NSString *languageCode = [locale localeIdentifier];
    
    if ([languageCode hasPrefix:@"ar"]) {
        [self setLanguage:@"ar"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"bg"]) {
        [self setLanguage:@"bg"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"bn"]) {
        [self setLanguage:@"bn"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"ca"]) {
        [self setLanguage:@"ca"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"cs"]) {
        [self setLanguage:@"cs"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"da"] && ![languageCode hasPrefix:@"dav"]) {
        [self setLanguage:@"da"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"de"]) {
        [self setLanguage:@"de"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"el"]) {
        [self setLanguage:@"el"];
        
        return;
    }
    
    if ([languageCode isEqualToString:@"en_AU"]) {
        [self setLanguage:@"en-AU"];
        
        return;
    }
    
    if ([languageCode isEqualToString:@"en_GB"]) {
        [self setLanguage:@"en-GB"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"en"]) {
        [self setLanguage:@"en"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"es"]) {
        [self setLanguage:@"es"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"eu"]) {
        [self setLanguage:@"eu"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"fa"]) {
        [self setLanguage:@"fa"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"fil"]) {
        [self setLanguage:@"fil"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"fi"]) {
        [self setLanguage:@"fi"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"fr"]) {
        [self setLanguage:@"fr"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"gl"]) {
        [self setLanguage:@"gl"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"gu_"]) {
        [self setLanguage:@"gu"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"hi"]) {
        [self setLanguage:@"hi"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"hr"]) {
        [self setLanguage:@"hr"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"hu"]) {
        [self setLanguage:@"hu"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"id"]) {
        [self setLanguage:@"id"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"it"]) {
        [self setLanguage:@"it"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"ja"]) {
        [self setLanguage:@"ja"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"kn"]) {
        [self setLanguage:@"kn"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"ko"] && ![languageCode hasPrefix:@"kok"]) {
        [self setLanguage:@"ko"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"lt"]) {
        [self setLanguage:@"lt"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"lv"]) {
        [self setLanguage:@"lv"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"ml"]) {
        [self setLanguage:@"ml"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"mr"]) {
        [self setLanguage:@"mr"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"nl"]) {
        [self setLanguage:@"nl"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"pl"]) {
        [self setLanguage:@"pl"];
        
        return;
    }
    
    if ([languageCode isEqualToString:@"pt_BR"]) {
        [self setLanguage:@"pt-BR"];
        
        return;
    }
    
    if ([languageCode isEqualToString:@"pt_PT"]) {
        [self setLanguage:@"pt-PT"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"pt"]) {
        [self setLanguage:@"pt"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"ro"] && ![languageCode hasPrefix:@"rof"]) {
        [self setLanguage:@"ro"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"ru"]) {
        [self setLanguage:@"ru"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"sk"]) {
        [self setLanguage:@"sk"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"sl"]) {
        [self setLanguage:@"sl"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"sr"]) {
        [self setLanguage:@"sr"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"sv"]) {
        [self setLanguage:@"sv"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"ta"]) {
        [self setLanguage:@"ta"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"te"] && ![languageCode hasPrefix:@"teo"]) {
        [self setLanguage:@"te"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"th"]) {
        [self setLanguage:@"th"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"tr"]) {
        [self setLanguage:@"tr"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"uk"]) {
        [self setLanguage:@"uk"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"vi"]) {
        [self setLanguage:@"vi"];
        
        return;
    }
    
    if ([languageCode hasPrefix:@"zh_Hant"]) {
        [self setLanguage:@"zh-TW"];
        
        return;
    }
    
    if ([languageCode isEqualToString:@"zh_Hans_CN"]) {
        [self setLanguage:@"zh-CN"];
        return;
    }
    
    [self setLanguage:@"en"];
}

- (void)startSearchWithCompletionHandler:(GPSSearchResult)handler
{
    if (_handler != nil) {
        Block_release(_handler);
    }
    
    _handler = Block_copy(handler);
    
    [self startSearch];
}

- (void)queryNextPage
{
    if (!self.hasNextPage) {
        return;
    }
    
    double delayInSeconds = 2.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self startSearch];
    });
}

#pragma mark - Private Method

- (NSString *)stringFromCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *string = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
    
    return string;
}

- (NSURLRequest *)requestWithParameters
{
    NSString *encodedQuery = [_query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    GPSServices *services = [GPSServices shareServices];
    NSString *APIKey = [services APIKey];
    
    NSMutableString *URLString = [NSMutableString stringWithString:DefaultURL];
    
#if TEXT_SEARCH
    [URLString appendFormat:@"query=%@", encodedQuery];
#else
    [URLString appendFormat:@"keyword=%@", encodedQuery];
#endif
    
    [URLString appendFormat:@"&key=%@", APIKey];
    [URLString appendFormat:@"&opennow=%@", self.openNow ? @"true" : @"false"];
    
    if (_isCoordinateChanged) {
        [URLString appendFormat:@"&location=%@", [self stringFromCoordinate:self.location]];
        [URLString appendFormat:@"&radius=%zd", self.radius];
    }
    
    if (self.language != nil) {
        [URLString appendFormat:@"&language=%@", self.language];
    }
    
    if (_nextPageToken != nil) {
        [URLString appendFormat:@"&pagetoken=%@", _nextPageToken];
    }
    
//    NSLog(@"URL: %@\n\n", URLString);
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    return request;
}

- (GPSErrorCode)errorCodeFromStatus:(NSString *)status
{
    if ([status isEqualToString:@"OVER_QUERY_LIMIT"]) {
        return GPSErrorCodeOverQueryLimit;
    }
    
    if ([status isEqualToString:@"REQUEST_DENIED"]) {
        return GPSErrorCodeRequestDenied;
    }
    
    if ([status isEqualToString:@"INVALID_REQUEST"]) {
        return GPSErrorCodeInvaldRequest;
    }
    
    return 0;
}

- (void)startSearch
{
    void (^completionsHandler) (NSData *data, NSURLResponse *response, NSError *error) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        GPSSearchResult responseHandler = ^(GPSSearchRequest *request, NSArray *places, NSError *error) {
            void (^operationBlock) (void) = ^{
                if (_handler != nil) {
                    _handler(request, places, error);
                }
            };
            
            NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
            [operationQueue addOperationWithBlock:operationBlock];
        };
        
        // Conection error.
        if (error != nil) {
            responseHandler(self, nil, error);
            
            return;
        }
        
        NSError *parseJsonError = nil;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseJsonError];
        
        // Perse json error.
        if (parseJsonError != nil) {
            responseHandler(self, nil, parseJsonError);
            
            return;
        }
        
//        NSLog(@"%@", jsonData);
        
        // Google api error.
        NSString *errorMessage = (NSString *)jsonData[@"error_message"];
        
        if (errorMessage != nil) {
            NSString *status = (NSString *)jsonData[@"status"];
            GPSErrorCode errorCode = [self errorCodeFromStatus:status];
            
            NSDictionary *usetInfo = @{NSLocalizedDescriptionKey: errorMessage};
            
            NSError *APIRequestError = [NSError errorWithDomain:@"com.googleapis.maps" code:errorCode userInfo:usetInfo];
            
            responseHandler(self, nil, APIRequestError);
            
            return;
        }
        
        // Handle next page token.
        [_nextPageToken release];
        _nextPageToken = nil;
        
        NSString *nextPageToken = (NSString *)jsonData[@"next_page_token"];
        [self setHasNextPage:(nextPageToken != nil)];
        
        if (self.hasNextPage) {
            _nextPageToken = [[NSString alloc] initWithString:nextPageToken];
        }
        
        // Parse place results
        NSArray *results = (NSArray *)jsonData[@"results"];
        NSEnumerator *enumerator = [results objectEnumerator];
        NSMutableArray *places = [NSMutableArray arrayWithCapacity:results.count];
        
        for (NSDictionary *dictionary in enumerator) {
            GPSPlaceItem *placeItem = [GPSPlaceItem placeItemWithDictionary:dictionary];
            
            [places addObject:placeItem];
        }
        
        responseHandler(self, places, nil);
    };
    
    NSURLRequest *request = [self requestWithParameters];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [NSOperationQueue new];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:queue];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:completionsHandler];
    [dataTask resume];
    
    [queue release];
}

#pragma mark - Key Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"location"]) {
        return;
    }
    
    _isCoordinateChanged = YES;
}

@end
