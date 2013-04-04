//
//  DAAppsViewController.h
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/3/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAAppsViewController : UITableViewController

@property (nonatomic) NSInteger artistId;

@property (nonatomic) BOOL onlyShowCompatibleApps;
@property (nonatomic) BOOL onlyShowOtherApps;
@property (nonatomic, copy) void(^didViewApp)(NSInteger appId);

+ (DAAppsViewController *)sharedInstance;

@end
