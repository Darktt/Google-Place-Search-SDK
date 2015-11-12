//
//  ViewController.m
//  GooglePlaceSearchDemo
//
//  Created by EdenLi on 2015/4/30.
//  Copyright (c) 2015年 Darktt. All rights reserved.
//

#import "ViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import "GooglePlaceSearch.h"

NS_ENUM(NSUInteger, ViewTags)
{
    kMapViewTag = 1000,
    kActivityView = 2000,
};

@interface ViewController () <UISearchBarDelegate>
{
    
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGRect mapViewFrame = (CGRect) {
        .size = (CGSize) {
            .width = CGRectGetWidth(screenRect),
            .height = CGRectGetHeight(screenRect)
        }
    };
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(22.6049, 120.3007);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:coordinate zoom:15.0f];
    
    GMSMapView *mapView = [GMSMapView mapWithFrame:mapViewFrame camera:camera];
    [mapView setTag:kMapViewTag];
    
    [self.view addSubview:mapView];
    
    CGRect searchBarFrame = (CGRect) {
        .origin = (CGPoint) {
            .y = 20.0f
        }
    };
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    [searchBar setBarTintColor:[UIColor clearColor]];
    [searchBar setBackgroundColor:[UIColor clearColor]];
    [searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [searchBar sizeToFit];
    [searchBar setDelegate:self];
    
    [self.view addSubview:searchBar];
    
    // Activity View
    {
        // Activity Indicator
        CGPoint centerOfActivityIndicator = CGPointMake(50.0f, 50.0f);
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] init];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator sizeToFit];
        [activityIndicator startAnimating];
        
        [activityIndicator setCenter:centerOfActivityIndicator];
        
        // Activity View
        CGRect activityViewFrame = (CGRect) {
            .origin = (CGPoint) {
                .x = CGRectGetMidX(screenRect) - 50.0f,
                .y = CGRectGetMidY(screenRect) - 50.0f
            },
            .size = CGSizeMake(100.0f, 100.0f)
        };
        
        UIColor *backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
        
        UIView *activityView = [[UIView alloc] initWithFrame:activityViewFrame];
        [activityView setBackgroundColor:backgroundColor];
        [activityView addSubview:activityIndicator];
        
        [activityView.layer setCornerRadius:5.0f];
        
        // Background
        CGRect activityBackgroundViewFrame = mapViewFrame;
        
        UIView *activityBackgroundView = [[UIView alloc] initWithFrame:activityBackgroundViewFrame];
        [activityBackgroundView setBackgroundColor:[UIColor clearColor]];
        [activityBackgroundView setTag:kActivityView];
        [activityBackgroundView addSubview:activityView];
        [activityBackgroundView setHidden:YES];
        
        [self.view addSubview:activityBackgroundView];
        
        // Clear UP
        [activityIndicator release];
        [activityView release];
        [activityBackgroundView release];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Other Methods

- (void)placeSearchWithQuery:(NSString *)query result:(void (^) (NSArray *places))result
{
    NSMutableArray *_places = [NSMutableArray array];
    
    GPSSearchResult _result = ^(GPSSearchRequest *request, NSArray *places, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error);
            
            return;
        }
        
        [_places addObjectsFromArray:places];
        
        if (request.hasNextPage) {
            [request queryNextPage];
        } else {
            result(_places);
        }
    };
    
    GMSMapView *mapView = (GMSMapView *)[self.view viewWithTag:kMapViewTag];
    GMSCameraPosition *camera = mapView.camera;
    CLLocationCoordinate2D coordinate = camera.target;
    
    NSString *string = [NSString stringWithFormat:@"Latitude: %.4f, Longitude: %.4f", coordinate.latitude, coordinate.longitude];
    NSLog(@"Search coordinate: %@", string);
    
    GPSSearchRequest *request = [GPSSearchRequest searchRequestWithQuery:query];
    [request setLocation:coordinate];
    [request setRadius:1000];
    [request setLanguage:@"zh-TW"];
    [request startSearchWithCompletionHandler:_result];
}

- (void)setActivityViewHidden:(BOOL)hidden
{
    UIView *activityBackgroundView = [self.view viewWithTag:kActivityView];
    [activityBackgroundView setHidden:hidden];
}

- (void)showZeroResultAlert
{
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Place not found!" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:OKAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self setActivityViewHidden:NO];
    [searchBar resignFirstResponder];
    
    GMSMapView *mapView = (GMSMapView *)[self.view viewWithTag:kMapViewTag];
    [mapView clear];
    
    void (^resultBlock) (NSArray *) = ^(NSArray *places) {
//        NSLog(@"Searched place count: %zd", places.count);
        
        if (places.count == 0) {
            [self showZeroResultAlert];
            [self setActivityViewHidden:YES];
            return;
        }
        
        NSEnumerator *enumerator = [places objectEnumerator];
        
        for (GPSPlaceItem *placeItem in enumerator) {
            GMSMarker *marker = [placeItem marker];
            [marker setMap:mapView];
        }
        
        [self setActivityViewHidden:YES];
    };
    
    [self placeSearchWithQuery:searchBar.text result:resultBlock];
}

@end
