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

- (id)initWithLockup:(NSDictionary *)lockup
{
    self = [super init];
    if (self) {
        _bundleId = [lockup objectForKey:@"bundle-id"];
        _name = [lockup objectForKey:@"name"];
        _genre = [lockup objectForKey:@"genre"];
        _appId = [[lockup objectForKey:@"id"] integerValue];
        _iconIsPrerendered = [[lockup objectForKey:@"icon-is-prerendered"] boolValue];
        _isUniversal = [[lockup objectForKey:@"is_universal_app"] boolValue];
        
        NSArray *offers = [lockup objectForKey:@"offers"];
        NSDictionary *offer = [offers lastObject];
        _formattedPrice = [offer objectForKey:@"button_text"];
        
        NSArray *artwork = [lockup objectForKey:@"artwork"];
        NSDictionary *artworkDictionary = [artwork objectAtIndex:MIN(artwork.count - 1, 2)];
        NSString *iconUrlString = [artworkDictionary objectForKey:@"url"];
        _iconURL = [[NSURL alloc] initWithString:iconUrlString];
        _userRating = [[lockup objectForKey:@"user_rating"] floatValue];
        _userRatingCount = [[lockup objectForKey:@"user_rating_count"] integerValue];
    }
    return self;
}

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
