//
//  GPSPlaceItem.h
//
//  Created by EdenLi on 2015/4/30.
//  Copyright (c) 2015年 Darktt. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class UIImage, GMSMarker;
@interface GPSPlaceItem : NSObject

@property (readonly) UIImage *icon;
@property (readonly) NSString *name;
@property (readonly) NSString *address;
@property (readonly) CLLocationCoordinate2D coordinate;

- (GMSMarker *)marker;

@end
