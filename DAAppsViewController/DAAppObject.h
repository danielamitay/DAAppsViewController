//
//  DAAppObject.h
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/5/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h> // For CGFloat

#define DA_IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface DAAppObject : NSObject

@property (nonatomic, readonly) NSInteger appId;
@property (nonatomic, readonly) NSInteger artistId;
@property (nonatomic, readonly) NSString *bundleId;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *genre;
@property (nonatomic, readonly) NSString *formattedPrice;
@property (nonatomic, readonly) NSURL *iconURL;

@property (nonatomic, readonly) NSInteger userRatingCount;
@property (nonatomic, readonly) CGFloat userRating;
@property (nonatomic, readonly) NSString *minimumOsVersion;
@property (nonatomic, readonly) BOOL isUniversal;

@property (nonatomic, readonly) BOOL isCompatible;

- (id)initWithResult:(NSDictionary *)result;

@end
