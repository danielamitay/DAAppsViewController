//
//  DAAppObject.m
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/5/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import "DAAppObject.h"

@implementation DAAppObject

#pragma mark - Equality methods

- (BOOL)isEqual:(id)other
{
    if (!other || ![other isKindOfClass:[self class]])
    {
        return NO;
    }
    else
    {
        return [self isEqualToAppObject:other];
    }
}

- (BOOL)isEqualToAppObject:(DAAppObject *)appObject
{
    if (self == appObject)
        return YES;
    else if (self.appId != appObject.appId)
        return NO;
    else if (self.artistId != appObject.artistId)
        return NO;
    else if (![self.bundleId isEqualToString:appObject.bundleId])
        return NO;
    else if (![self.name isEqualToString:appObject.name])
        return NO;
    else if (![self.genre isEqualToString:appObject.genre])
        return NO;
    else if (![self.formattedPrice isEqualToString:appObject.formattedPrice])
        return NO;
    else if (![self.iconURL isEqual:appObject.iconURL])
        return NO;
    else if (self.iconIsPrerendered != appObject.iconIsPrerendered)
        return NO;
    else if (self.isUniversal != appObject.isUniversal)
        return NO;
    else if (self.userRatingCount != appObject.userRatingCount)
        return NO;
    else if (self.userRating != appObject.userRating)
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    return self.appId ^ self.userRatingCount;
}

@end
