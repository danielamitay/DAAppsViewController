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
    {
        return YES;
    }
    else if (self.appId != appObject.appId)
    {
        return NO;
    }
    else if (self.artistId != appObject.artistId)
    {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash
{
    return self.appId ^ self.artistId;
}

@end
