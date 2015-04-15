//
//  DAAppsViewController.m
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/3/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import "DAAppsViewController.h"
#import <StoreKit/StoreKit.h>
#import "DAAppViewCell.h"

#define DARK_BACKGROUND_COLOR   [UIColor colorWithWhite:235.0f/255.0f alpha:1.0f]
#define LIGHT_BACKGROUND_COLOR  [UIColor colorWithWhite:245.0f/255.0f alpha:1.0f]

@interface DAAppsViewController () <SKStoreProductViewControllerDelegate> {
    BOOL _isLoading;
    NSString *_defaultTitle;
}

@property (nonatomic, copy) NSArray *appsArray;

- (void)presentAppObjectAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation DAAppsViewController

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 83.0f;
    if (!DA_IS_IOS7) {
        self.tableView.backgroundColor = DARK_BACKGROUND_COLOR;
    }
    
    UIView *tableFooterView = [[UIView alloc] init];
    tableFooterView.backgroundColor = [UIColor whiteColor];
    tableFooterView.frame = (CGRect) {
        .size.width = self.tableView.frame.size.width,
        .size.height = 1.0f
    };
    self.tableView.tableFooterView = tableFooterView;
}


#pragma mark - Property methods

- (void)setAppsArray:(NSArray *)appsArray
{
    _appsArray = appsArray;
    [self.tableView reloadData];
    self.tableView.contentOffset = (CGPoint) {
        .y = -self.tableView.contentInset.top
    };
}

- (void)setShouldShowIncompatibleApps:(BOOL)shouldShowIncompatibleApps
{
    _shouldShowIncompatibleApps = shouldShowIncompatibleApps;
    [self.tableView reloadData];
}

- (void)setBlockedApps:(NSArray *)blockedApps
{
    _blockedApps = blockedApps;
    [self.tableView reloadData];
}

- (void)setPageTitle:(NSString *)pageTitle
{
    _pageTitle = [pageTitle copy];
    [self updateTitle];
}

- (void)updateTitle
{
    if (_isLoading) {
        self.title = NSLocalizedString(@"Loading...",);
    } else {
        self.title = (self.pageTitle.length ? self.pageTitle : _defaultTitle);
    }
}


#pragma mark - Loading methods

- (void)loadRequestPath:(NSString *)path withCompletion:(void (^)(NSArray *results, NSError *error))completion
{
    NSMutableString *requestUrlString = [[NSMutableString alloc] init];
    [requestUrlString appendString:@"http://itunes.apple.com/"];
    [requestUrlString appendString:path];
    [requestUrlString appendFormat:@"&entity=software"];
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (countryCode) {
        [requestUrlString appendFormat:@"&country=%@", countryCode];
    }
    NSString *languagueCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    if (languagueCode) {
        [requestUrlString appendFormat:@"&l=%@", languagueCode];
    }

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:requestUrlString]];
    [request setTimeoutInterval:20.0f];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];

    void (^returnWithResultsAndError)(NSArray *, NSError *) = ^void(NSArray *results, NSError *error) {
        if (completion) {
            completion(results, error);
        }
    };

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            return returnWithResultsAndError(nil, connectionError);
        }

        NSError *jsonError;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            return returnWithResultsAndError(nil, jsonError);
        }

        NSArray *results = [jsonDictionary objectForKey:@"results"];
        returnWithResultsAndError(results, nil);
    }];
}

- (void)loadAppsWithPath:(NSString *)path defaultTitle:(NSString *)defaultTitle completionBlock:(void(^)(BOOL result, NSError *error))block
{
    _isLoading = YES;
    _defaultTitle = defaultTitle;
    [self updateTitle];
    [self loadRequestPath:path withCompletion:^(NSArray *results, NSError *error) {
        _isLoading = NO;
        if (error) {
            _defaultTitle = NSLocalizedString(@"Error",);
            if (block) {
                block(NO, error);
            }
        } else {
            NSMutableArray *mutableApps = [[NSMutableArray alloc] init];
            for (NSDictionary *result in results) {
                BOOL isArtistWrapper = [[result objectForKey:@"wrapperType"] isEqualToString:@"artist"];
                if (isArtistWrapper) {
                    NSString *artistName = [result objectForKey:@"artistName"];
                    if (artistName) {
                        _defaultTitle = artistName;
                    }
                }
                DAAppObject *appObject = [[DAAppObject alloc] initWithResult:result];
                if (appObject && ![mutableApps containsObject:appObject]) {
                    [mutableApps addObject:appObject];
                }
            }
            self.appsArray = mutableApps;
            if (block) {
                block(YES, nil);
            }
        }
        [self updateTitle];
    }];
}


#pragma mark - Public methods

- (void)loadAllAppsWithArtistId:(NSInteger)artistId completionBlock:(void(^)(BOOL result, NSError *error))block
{
    [self loadAppsWithArtistId:artistId completionBlock:block];
}

- (void)loadAppsWithArtistId:(NSInteger)artistId completionBlock:(void(^)(BOOL result, NSError *error))block
{
    NSString *requestPath = [NSString stringWithFormat:@"lookup?id=%ld", (long)artistId];
    [self loadAppsWithPath:requestPath defaultTitle:NSLocalizedString(@"Results",) completionBlock:block];
}

- (void)loadAppsWithAppIds:(NSArray *)appIds completionBlock:(void(^)(BOOL result, NSError *error))block
{
    NSString *appString = [appIds componentsJoinedByString:@","];
    NSString *requestPath = [NSString stringWithFormat:@"lookup?id=%@", appString];
    [self loadAppsWithPath:requestPath defaultTitle:NSLocalizedString(@"Results",) completionBlock:block];
}

- (void)loadAppsWithBundleIds:(NSArray *)bundleIds completionBlock:(void(^)(BOOL result, NSError *error))block
{
    NSString *bundleString = [bundleIds componentsJoinedByString:@","];
    NSString *requestPath = [NSString stringWithFormat:@"lookup?bundleId=%@", bundleString];
    [self loadAppsWithPath:requestPath defaultTitle:NSLocalizedString(@"Results",) completionBlock:block];
}

- (void)loadAppsWithSearchTerm:(NSString *)searchTerm completionBlock:(void(^)(BOOL result, NSError *error))block
{
    NSString *escapedSearchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *requestPath = [NSString stringWithFormat:@"search?term=%@", escapedSearchTerm];
    [self loadAppsWithPath:requestPath defaultTitle:searchTerm completionBlock:block];
}


#pragma mark - Table view data source

- (NSArray *)compatibleAppsArray
{
    if (self.shouldShowIncompatibleApps) {
        return self.appsArray;
    } else {
        NSPredicate *compatiblePredicate = [NSPredicate predicateWithFormat:@"isCompatible = YES"];
        if (self.blockedApps.count) {
            NSPredicate *appIdsPredicate = [NSPredicate predicateWithFormat:@"NOT (appId IN %@)", self.blockedApps];
            NSPredicate *bundleIdsPredicate = [NSPredicate predicateWithFormat:@"NOT (bundleId IN %@)", self.blockedApps];
            compatiblePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[compatiblePredicate, appIdsPredicate, bundleIdsPredicate]];
        }
        return [self.appsArray filteredArrayUsingPredicate:compatiblePredicate];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.compatibleAppsArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!DA_IS_IOS7) {
        cell.backgroundColor = (indexPath.row % 2 ? DARK_BACKGROUND_COLOR : LIGHT_BACKGROUND_COLOR);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DAAppViewCell *cell = (DAAppViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[DAAppViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.appObject = [self.compatibleAppsArray objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self presentAppObjectAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self presentAppObjectAtIndexPath:indexPath];
}


#pragma mark - Presentation methods

- (void)presentAppObjectAtIndexPath:(NSIndexPath *)indexPath
{
    DAAppObject *appObject = [self.compatibleAppsArray objectAtIndex:indexPath.row];
    
    if (self.didViewAppBlock) {
        self.didViewAppBlock(appObject.appId);
    }
    
    if ([SKStoreProductViewController class]) {
        NSString *itunesItemIdentifier = [NSString stringWithFormat:@"%ld",  (long)appObject.appId];
        NSMutableDictionary *appParameters = [@{SKStoreProductParameterITunesItemIdentifier: itunesItemIdentifier} mutableCopy];
        
#ifdef __IPHONE_8_0
        if (&SKStoreProductParameterAffiliateToken) {
            if (self.affiliateToken) {
                [appParameters setObject:self.affiliateToken forKey:SKStoreProductParameterAffiliateToken];
                if (self.campaignToken) {
                    [appParameters setObject:self.campaignToken forKey:SKStoreProductParameterCampaignToken];
                }
            }
        }
#endif
        
        SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
        [productViewController setDelegate:self];
        [productViewController loadProductWithParameters:appParameters completionBlock:nil];
        [self presentViewController:productViewController
                           animated:YES
                         completion:nil];
    } else {
        NSString *appUrlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%ld?mt=8", (long)appObject.appId];
        NSURL *appURL = [[NSURL alloc] initWithString:appUrlString];
        [[UIApplication sharedApplication] openURL:appURL];
    }
}


#pragma mark - Product view controller delegate methods

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
