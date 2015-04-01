//
//  DAAppObject.m
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/5/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import "DAAppObject.h"
#import <UIKit/UIKit.h> // For UIDevice, UIUserInterfaceIdiom

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
        _genre = [[result objectForKey:@"genres"] objectAtIndex:0]; // for genre with different language.
        _appId = [[result objectForKey:@"trackId"] integerValue];

        NSArray *features = [result objectForKey:@"features"];
        _isUniversal = [features containsObject:@"iosUniversal"];
        _minimumOsVersion = [result objectForKey:@"minimumOsVersion"];
        _formattedPrice = [[result objectForKey:@"formattedPrice"] uppercaseString];
        NSString *iconUrlString = [result objectForKey:@"artworkUrl100"];
        _iconURL = [[NSURL alloc] initWithString:iconUrlString];
        _userRating = [[result objectForKey:@"averageUserRating"] floatValue];
        _userRatingCount = [[result objectForKey:@"userRatingCount"] integerValue];

        // App compatibility check
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        // Apps are only compatible if the current OS is above the minimum version
        if ([_minimumOsVersion compare:systemVersion options:NSNumericSearch] != NSOrderedDescending) {
            if (_isUniversal) {
                // App is universally compatible
                _isCompatible = YES;
            } else {
                UIUserInterfaceIdiom interfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
                switch (interfaceIdiom) {
                    case UIUserInterfaceIdiomPhone: {
                        // App is only compatible with Phone if it contains screenshot urls
                        NSArray *screenshotUrls = [result objectForKey:@"screenshotUrls"];
                        _isCompatible = (screenshotUrls.count > 0);
                    }   break;
                    case UIUserInterfaceIdiomPad: {
                        // App is compatible with Pad if it contains screenshot urls
                        NSArray *screenshotUrls = [result objectForKey:@"screenshotUrls"];
                        if (screenshotUrls.count > 0) {
                            _isCompatible = YES;
                        } else {
                            // Or if it contains ipad screenshot urls
                            NSArray *ipadScreenshotUrls = [result objectForKey:@"ipadScreenshotUrls"];
                            _isCompatible = (ipadScreenshotUrls.count > 0);
                        }
                    }   break;
                    default: {
                        // Future interface idiom? Better to display incompatible apps than none at all
                        _isCompatible = YES;
                    }   break;
                }
            }
        }
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
