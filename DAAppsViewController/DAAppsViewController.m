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

@interface DAAppsViewController () <SKStoreProductViewControllerDelegate> {
    BOOL _isLoading;
    NSString *_defaultTitle;
}

@property (nonatomic, copy) NSArray<DAAppObject *> *appsArray;

@end

@implementation DAAppsViewController

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 82.0f;
}


#pragma mark - Property methods

- (void)setAppsArray:(NSArray<DAAppObject *> *)appsArray
{
    _appsArray = appsArray;
    [self.tableView reloadData];
}

- (void)setShouldShowIncompatibleApps:(BOOL)shouldShowIncompatibleApps
{
    _shouldShowIncompatibleApps = shouldShowIncompatibleApps;
    [self.tableView reloadData];
}

- (void)setBlockedApps:(NSArray<id> *)blockedApps
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

- (void)_loadRequestPath:(NSString *)path withCompletion:(void (^)(NSArray<NSDictionary *> *results, NSError *error))completion
{
    NSMutableString *requestUrlString = [[NSMutableString alloc] init];
    [requestUrlString appendString:@"https://itunes.apple.com/"];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(results, error);
            });
        }
    };

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, id res, NSError *err) {
        if (err) {
            return returnWithResultsAndError(nil, err);
        }
        NSError *jsonError;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            return returnWithResultsAndError(nil, jsonError);
        }
        NSArray *results = [jsonDictionary objectForKey:@"results"];
        returnWithResultsAndError(results, nil);
    }] resume];
}

- (void)_loadAppsWithPath:(NSString *)path defaultTitle:(NSString *)defaultTitle completionBlock:(void(^)(BOOL result, NSError *error))block
{
    _isLoading = YES;
    _defaultTitle = defaultTitle;
    [self updateTitle];

    __weak typeof(self) wSelf = self;
    [self _loadRequestPath:path withCompletion:^(NSArray<NSDictionary *> *results, NSError *error) {
        [wSelf _didLoadApps:results error:error completionBlock:block];
    }];
}

- (void)_didLoadApps:(NSArray<NSDictionary *> *)results error:(NSError *)error completionBlock:(void(^)(BOOL result, NSError *error))block
{
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
}


#pragma mark - Public methods

- (void)loadAppsWithArtistId:(NSInteger)artistId completionBlock:(void(^)(BOOL result, NSError *error))block
{
    NSString *requestPath = [NSString stringWithFormat:@"lookup?id=%ld", (long)artistId];
    [self _loadAppsWithPath:requestPath defaultTitle:NSLocalizedString(@"Results",) completionBlock:block];
}

- (void)loadAppsWithAppIds:(NSArray<NSNumber *> *)appIds completionBlock:(void(^)(BOOL result, NSError *error))block
{
    NSString *appString = [appIds componentsJoinedByString:@","];
    NSString *requestPath = [NSString stringWithFormat:@"lookup?id=%@", appString];
    [self _loadAppsWithPath:requestPath defaultTitle:NSLocalizedString(@"Results",) completionBlock:block];
}

- (void)loadAppsWithBundleIds:(NSArray<NSString *> *)bundleIds completionBlock:(void(^)(BOOL result, NSError *error))block
{
    NSString *bundleString = [bundleIds componentsJoinedByString:@","];
    NSString *requestPath = [NSString stringWithFormat:@"lookup?bundleId=%@", bundleString];
    [self _loadAppsWithPath:requestPath defaultTitle:NSLocalizedString(@"Results",) completionBlock:block];
}

- (void)loadAppsWithSearchTerm:(NSString *)searchTerm completionBlock:(void(^)(BOOL result, NSError *error))block
{
    NSCharacterSet *allowedCharacters = [NSCharacterSet whitespaceAndNewlineCharacterSet].invertedSet;
    NSString *escapedSearchTerm = [searchTerm stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    NSString *requestPath = [NSString stringWithFormat:@"search?term=%@", escapedSearchTerm];
    [self _loadAppsWithPath:requestPath defaultTitle:searchTerm completionBlock:block];
}


#pragma mark - Table view data source

- (NSArray<DAAppObject *> *)compatibleAppsArray
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
    [self _presentAppObjectAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self _presentAppObjectAtIndexPath:indexPath];
}


#pragma mark - Presentation methods

- (void)_presentAppObjectAtIndexPath:(NSIndexPath *)indexPath
{
    DAAppObject *appObject = [self.compatibleAppsArray objectAtIndex:indexPath.row];

    NSString *itunesItemIdentifier = [NSString stringWithFormat:@"%ld",  (long)appObject.appId];
    NSDictionary<NSString *, id> *parameters = @{ SKStoreProductParameterITunesItemIdentifier: itunesItemIdentifier };

    SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
    [productViewController setDelegate:self];
    [productViewController loadProductWithParameters:parameters completionBlock:nil];
    [self presentViewController:productViewController
                       animated:YES
                     completion:nil];
}


#pragma mark - Product view controller delegate methods

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
