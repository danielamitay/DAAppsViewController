//
//  DAAppsViewController.h
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/3/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAAppsViewController : UITableViewController

// Customized title of the view controller.
// It should be set before calling loadAppsWithXXX methods.
// If it is nil, the title will be the artist/company name or 'Results'.
@property (nonatomic, copy) NSString *pageTitle;

@property (nonatomic) BOOL shouldShowIncompatibleApps;

// A list of bundle ids or app ids of apps that should not be displayed.
@property (nonatomic, copy) NSArray<id> *blockedApps;

- (void)loadAppsWithArtistId:(NSInteger)artistId completionBlock:(void(^)(BOOL result, NSError *error))block;
- (void)loadAppsWithAppIds:(NSArray<NSNumber *> *)appIds completionBlock:(void(^)(BOOL result, NSError *error))block;
- (void)loadAppsWithBundleIds:(NSArray<NSString *> *)bundleIds completionBlock:(void(^)(BOOL result, NSError *error))block;
- (void)loadAppsWithSearchTerm:(NSString *)searchTerm completionBlock:(void(^)(BOOL result, NSError *error))block;

@end
