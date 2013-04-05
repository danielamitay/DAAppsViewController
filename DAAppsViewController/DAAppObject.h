//
//  DAAppObject.h
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/5/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAAppObject : NSObject

@property (nonatomic) NSInteger appId;
@property (nonatomic) NSInteger artistId;
@property (nonatomic, copy) NSString *bundleId;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, copy) NSString *formattedPrice;
@property (nonatomic, copy) NSURL *iconURL;
@property (nonatomic) BOOL iconIsPrerendered;

@property (nonatomic) NSInteger userRatingCount;
@property (nonatomic) CGFloat userRating;
@property (nonatomic) BOOL isUniversal;

@end
