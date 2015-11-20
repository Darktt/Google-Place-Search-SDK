//
//  GPSPlaceItem.m
//
//  Created by EdenLi on 2015/4/30.
//  Copyright (c) 2015年 Darktt. All rights reserved.
//

#import "GPSPlaceItem.h"

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

NSString * const kGPSPlaceItemIconKey = @"icon";
NSString * const kGPSPlaceItemNameKey = @"name";
NSString * const kGPSPlaceItemAddressKey = @"formatted_address";
NSString * const kGPSPlaceItemGeometryKey = @"geometry";
NSString * const kGPSPlaceItemLocationKey = @"location";
NSString * const kGPSPlaceItemLatitudeKey = @"lat";
NSString * const kGPSPlaceItemLongitudeKey = @"lng";

@interface GPSPlaceItem ()
{
    NSURL *_iconURL;
}

@property (retain, nonatomic) UIImage *icon;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *address;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

+ (instancetype)placeItemWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@implementation GPSPlaceItem

+ (instancetype)placeItemWithDictionary:(NSDictionary *)dictionary
{
    GPSPlaceItem *placeItem = [[GPSPlaceItem alloc] initWithDictionary:dictionary];
    
    return [placeItem autorelease];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    if (self == nil) return nil;
    
    NSString *iconURLString = (NSString *)dictionary[kGPSPlaceItemIconKey];
    _iconURL = [[NSURL alloc] initWithString:iconURLString];
    
    NSString *name = (NSString *)dictionary[kGPSPlaceItemNameKey];
    NSString *address = (NSString *)dictionary[kGPSPlaceItemAddressKey];
    NSDictionary *geometry = (NSDictionary *)dictionary[kGPSPlaceItemGeometryKey];
    NSDictionary *location = (NSDictionary *)geometry[kGPSPlaceItemLocationKey];
    NSNumber *latitudeNumber = (NSNumber *)location[kGPSPlaceItemLatitudeKey];
    NSNumber *longitudeNumber = (NSNumber *)location[kGPSPlaceItemLongitudeKey];
    
    CLLocationCoordinate2D coordinate = (CLLocationCoordinate2D) {
        .latitude = latitudeNumber.doubleValue,
        .longitude = longitudeNumber.doubleValue
    };
    
    [self setName:name];
    [self setAddress:address];
    [self setCoordinate:coordinate];
    
    [self queryIconImage];
    
    return self;
}

- (void)dealloc
{
    [_iconURL release];
    
    [self setIcon:nil];
    [self setName:nil];
    [self setAddress:nil];
    
    [super dealloc];
}

- (NSString *)description
{
    NSString *(^NSStringFromCoordinate) (CLLocationCoordinate2D coordinate) = ^NSString * (CLLocationCoordinate2D coordinate) {
        return [NSString stringWithFormat:@"Latitude: %.4f, Longitude: %.4f", coordinate.latitude, coordinate.longitude];
    };
    
    NSMutableString *description = [NSMutableString stringWithFormat:@"<GPSPlaceItem %p> {\r\r", self];
    [description appendFormat:@"name: %@\r\r", self.name];
    [description appendFormat:@"address: %@\r\r", self.address];
    [description appendFormat:@"%@\r\r}", NSStringFromCoordinate(self.coordinate)];
    
    return description;
}

#pragma mark - Public Method

- (GMSMarker *)marker
{
    GMSMarker *marker = [GMSMarker markerWithPosition:self.coordinate];
//    [marker setIcon:self.icon];
    [marker setTitle:self.name];
    
    return marker;
}

#pragma mark - Privare Method

- (NSString *)cachesPathWithFileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = paths.firstObject;
    
    return [cachesPath stringByAppendingPathComponent:fileName];
}

- (void)queryIconImage
{
    NSString *fileName = [_iconURL lastPathComponent];
    NSString *savePath = [self cachesPathWithFileName:fileName];
    
    void (^completionsHandler) (NSURL *location, NSURLResponse *response, NSError *error) =^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            NSLog(@"Icon download fail: %@", error);
            
            return;
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:savePath]) {
            [fileManager moveItemAtPath:[location absoluteString] toPath:savePath error:nil];
        }
        
        UIImage *iconImage = [UIImage imageWithContentsOfFile:savePath];
        [self setIcon:iconImage];
    };
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [NSOperationQueue new];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:queue];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:_iconURL completionHandler:completionsHandler];
    [downloadTask resume];
    
    [queue release];
}

@end
