//
//  DAAppObject.m
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/5/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import "DAAppObject.h"

@implementation DAAppObject

- (id)initWithResult:(NSDictionary *)result
{
    NSString *kind = [result objectForKey:@"kind"];
    if (![kind isEqualToString:@"software"]) {
        return nil;
    }
    self = [super init];
    if (self) {
        _bundleId = [result objectForKey:@"bundleId"];
        _name = [result objectForKey:@"trackName"];
        _genre = [result objectForKey:@"primaryGenreName"];
        _appId = [[result objectForKey:@"trackId"] integerValue];
        _iconIsPrerendered = DA_IS_IOS7;

        NSArray *features = [result objectForKey:@"features"];
        _isUniversal = [features containsObject:@"iosUniversal"];
        _formattedPrice = [[result objectForKey:@"formattedPrice"] uppercaseString];
        //NSString *iconUrlString = [result objectForKey:@"artworkUrl60"];
        NSString *iconUrlString = [result objectForKey:@"artworkUrl512"];
        NSArray *iconUrlComponents = [iconUrlString componentsSeparatedByString:@"."];
        NSMutableArray *mutableIconURLComponents = [[NSMutableArray alloc] initWithArray:iconUrlComponents];
        [mutableIconURLComponents insertObject:@"128x128-75" atIndex:mutableIconURLComponents.count-1];
        iconUrlString = [mutableIconURLComponents componentsJoinedByString:@"."];

        _iconURL = [[NSURL alloc] initWithString:iconUrlString];
        _userRating = [[result objectForKey:@"averageUserRating"] floatValue];
        _userRatingCount = [[result objectForKey:@"userRatingCount"] integerValue];
    }
    return self;
}


#pragma mark - Equality methods

- (BOOL)isEqual:(id)other
{
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    } else {
        return [self isEqualToAppObject:other];
    }
}

- (BOOL)isEqualToAppObject:(DAAppObject *)appObject
{
    if (self == appObject) {
        return YES;
    } else if (self.appId != appObject.appId) {
        return NO;
    } else if (self.artistId != appObject.artistId) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash
{
    return self.appId ^ self.artistId;
}

@end
