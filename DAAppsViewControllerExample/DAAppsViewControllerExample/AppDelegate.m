//
//  AppDelegate.m
//  DAAppsViewControllerExample
//
//  Created by Daniel Amitay on 7/18/23.
//

#import "AppDelegate.h"

#import "RootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    RootViewController *viewController = [[RootViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];

    [self.window makeKeyAndVisible];

    return YES;
}

@end
