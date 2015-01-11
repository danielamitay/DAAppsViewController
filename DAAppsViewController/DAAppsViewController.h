//
//  DAAppsViewController.h
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/3/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAAppsViewController : UITableViewController

@property (nonatomic, copy) void(^didViewAppBlock)(NSInteger appId);

// Customized title of the view controller.
// It should be set before calling loadAppsWithXXX methods.
// If it is nil, the title will be the artist/company name or 'Results'.
@property (nonatomic, copy) NSString *pageTitle;

@property (nonatomic) BOOL shouldShowIncompatibleApps;

// A list of bundle ids or app ids of apps that should not be displayed.
@property (nonatomic, copy) NSArray *blockedApps;


#ifdef __IPHONE_8_0
@property (nonatomic, strong) NSString *affiliateToken;
@property (nonatomic, strong) NSString *campaignToken;
#endif

- (void)loadAppsWithArtistId:(NSInteger)artistId completionBlock:(void(^)(BOOL result, NSError *error))block;
- (void)loadAppsWithAppIds:(NSArray *)appIds completionBlock:(void(^)(BOOL result, NSError *error))block;
- (void)loadAppsWithBundleIds:(NSArray *)bundleIds completionBlock:(void(^)(BOOL result, NSError *error))block;
- (void)loadAppsWithSearchTerm:(NSString *)searchTerm completionBlock:(void(^)(BOOL result, NSError *error))block;


// DEPRECATED (use `shouldShowIncompatibleApps` instead)
- (void)loadAllAppsWithArtistId:(NSInteger)artistId completionBlock:(void(^)(BOOL result, NSError *error))block DEPRECATED_ATTRIBUTE;

@end
