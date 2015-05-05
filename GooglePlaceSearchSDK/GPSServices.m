//
//  GPSServices.m
//
//  Created by EdenLi on 2015/4/30.
//  Copyright (c) 2015年 Darktt. All rights reserved.
//

#import "GPSServices.h"

static GPSServices *singletion = nil;

@interface GPSServices ()

@property (retain, nonatomic) NSString *APIKey;

+ (instancetype)shareServices;

@end

@implementation GPSServices

+ (instancetype)shareServices
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletion = [GPSServices new];
    });
    
    return singletion;
}

+ (void)provideAPIKey:(NSString *)APIKey
{
    GPSServices *service = [GPSServices shareServices];
    [service setAPIKey:APIKey];
}

@end
