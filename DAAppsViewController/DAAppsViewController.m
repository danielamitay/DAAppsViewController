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

#define USER_AGENT              @"iTunes-iPad/6.0 (6; 16GB; dt:73)"
#define DARK_BACKGROUND_COLOR   [UIColor colorWithWhite:235.0f/255.0f alpha:1.0f]
#define LIGHT_BACKGROUND_COLOR  [UIColor colorWithWhite:245.0f/255.0f alpha:1.0f]

@interface DAAppsViewController () <NSURLConnectionDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSArray *appsArray;

- (NSDictionary *)resultsDictionaryForURL:(NSURL *)URL error:(NSError **)error;
- (void)presentAppObjectAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation DAAppsViewController

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 83.0f;
    self.tableView.backgroundColor = DARK_BACKGROUND_COLOR;
    
    UIView *tableFooterView = [[UIView alloc] init];
    tableFooterView.backgroundColor = [UIColor whiteColor];
    tableFooterView.frame = (CGRect) {
        .size.width = self.tableView.frame.size.width,
        .size.height = 1.0f
    };
    self.tableView.tableFooterView = tableFooterView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setContentOffset:CGPointZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Property methods

- (void)setAppsArray:(NSArray *)appsArray
{
    _appsArray = appsArray;
    [self.tableView reloadData];
}

#pragma mark - Loading methods

- (NSDictionary *)resultsDictionaryForURL:(NSURL *)URL error:(NSError **)error
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:URL];
    [request setTimeoutInterval:20.0f];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
    
    NSError *connectionError;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:NULL
                                                       error:&connectionError];
    if (connectionError)
    {
        *error = connectionError;
        return nil;
    }
    NSError *jsonError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:result
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonError];
    *error = jsonError;
    return jsonDictionary;
}

- (void)loadAppsWithArtistId:(NSInteger)artistId completionBlock:(void(^)(BOOL result, NSError *error))block
{
    self.title = NSLocalizedString(@"Loading...",);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        NSMutableString *requestUrlString = [[NSMutableString alloc] init];
        [requestUrlString appendFormat:@"http://itunes.apple.com/"];
        if (countryCode)
        {
            [requestUrlString appendFormat:@"%@/", countryCode];
        }
        [requestUrlString appendFormat:@"artist/id%i", artistId];
        [requestUrlString appendFormat:@"?dataOnly=true"];
        NSURL *requestURL = [[NSURL alloc] initWithString:requestUrlString];
        
        NSError *requestError;
        NSDictionary *jsonObject = [self resultsDictionaryForURL:requestURL error:&requestError];
        if (requestError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block)
                {
                    block(FALSE, requestError);
                }
            });
        }
        else
        {
            NSDictionary *artistDictionary = jsonObject;
            NSArray *stack = [artistDictionary objectForKey:@"stack"];
            NSString *pageTitle = [artistDictionary objectForKey:@"pageTitle"];
            
            NSMutableArray *mutableApps = [[NSMutableArray alloc] init];
            for (NSDictionary *swoosh in stack)
            {
                NSArray *content = [swoosh objectForKey:@"content"];
                for (NSDictionary *lockup in content)
                {
                    DAAppObject *appObject = [[DAAppObject alloc] init];
                    
                    appObject.bundleId = [lockup objectForKey:@"bundle-id"];
                    appObject.name = [lockup objectForKey:@"name"];
                    appObject.genre = [lockup objectForKey:@"genre"];
                    appObject.appId = [[lockup objectForKey:@"id"] integerValue];
                    appObject.iconIsPrerendered = [[lockup objectForKey:@"icon-is-prerendered"] boolValue];
                    appObject.isUniversal = [[lockup objectForKey:@"is_universal_app"] boolValue];
                    
                    NSArray *offers = [lockup objectForKey:@"offers"];
                    NSDictionary *offer = [offers lastObject];
                    appObject.formattedPrice = [offer objectForKey:@"button_text"];
                    
                    NSArray *artwork = [lockup objectForKey:@"artwork"];
                    NSDictionary *artworkDictionary = [artwork objectAtIndex:MIN(artwork.count - 1, 2)];
                    NSString *iconUrlString = [artworkDictionary objectForKey:@"url"];
                    appObject.iconURL = [[NSURL alloc] initWithString:iconUrlString];
                    appObject.userRating = [[lockup objectForKey:@"user_rating"] floatValue];
                    appObject.userRatingCount = [[lockup objectForKey:@"user_rating_count"] integerValue];
                    
                    if (![mutableApps containsObject:appObject])
                    {
                        [mutableApps addObject:appObject];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = pageTitle;
                self.appsArray = mutableApps;
                [self.tableView reloadData];
                if (block)
                {
                    block(TRUE, NULL);
                }
            });
        }
    });
}

- (void)loadAppsWithAppIds:(NSArray *)appIds completionBlock:(void(^)(BOOL result, NSError *error))block
{
    self.title = NSLocalizedString(@"Loading...",);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *appString = [appIds componentsJoinedByString:@","];
        NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        NSMutableString *requestUrlString = [[NSMutableString alloc] init];
        [requestUrlString appendFormat:@"http://itunes.apple.com/lookup"];
        [requestUrlString appendFormat:@"?id=%@", appString];
        if (countryCode)
        {
            [requestUrlString appendFormat:@"&country=%@", countryCode];
        }
        NSURL *requestURL = [[NSURL alloc] initWithString:requestUrlString];
        
        NSError *requestError;
        NSDictionary *jsonObject = [self resultsDictionaryForURL:requestURL error:&requestError];
        if (requestError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block)
                {
                    block(FALSE, requestError);
                }
            });
        }
        else
        {
            NSDictionary *appsDictionary = jsonObject;
            NSArray *results = [appsDictionary objectForKey:@"results"];
            NSString *pageTitle = @"Results";
            
            NSMutableArray *mutableApps = [[NSMutableArray alloc] init];
            for (NSDictionary *result in results)
            {
                DAAppObject *appObject = [[DAAppObject alloc] init];
                
                appObject.bundleId = [result objectForKey:@"bundleId"];
                appObject.name = [result objectForKey:@"trackName"];
                appObject.genre = [result objectForKey:@"primaryGenreName"];
                appObject.appId = [[result objectForKey:@"trackId"] integerValue];
                
                NSArray *features = [result objectForKey:@"features"];
                appObject.isUniversal = [features containsObject:@"iosUniversal"];
                appObject.formattedPrice = [[result objectForKey:@"formattedPrice"] uppercaseString];
                //NSString *iconUrlString = [result objectForKey:@"artworkUrl60"];
                NSString *iconUrlString = [result objectForKey:@"artworkUrl512"];
                NSArray *iconUrlComponents = [iconUrlString componentsSeparatedByString:@"."];
                NSMutableArray *mutableIconURLComponents = [[NSMutableArray alloc] initWithArray:iconUrlComponents];
                [mutableIconURLComponents insertObject:@"128x128-75" atIndex:mutableIconURLComponents.count-1];
                iconUrlString = [mutableIconURLComponents componentsJoinedByString:@"."];
                
                appObject.iconURL = [[NSURL alloc] initWithString:iconUrlString];
                appObject.userRating = [[result objectForKey:@"averageUserRating"] floatValue];
                appObject.userRatingCount = [[result objectForKey:@"userRatingCount"] integerValue];
                
                if (![mutableApps containsObject:appObject])
                {
                    [mutableApps addObject:appObject];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = pageTitle;
                self.appsArray = mutableApps;
                [self.tableView reloadData];
                if (block)
                {
                    block(TRUE, NULL);
                }
            });
        }
    });
}

- (void)loadAppsWithBundleIds:(NSArray *)bundleIds completionBlock:(void(^)(BOOL result, NSError *error))block
{
    self.title = NSLocalizedString(@"Loading...",);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *bundleString = [bundleIds componentsJoinedByString:@","];
        NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        NSMutableString *requestUrlString = [[NSMutableString alloc] init];
        [requestUrlString appendFormat:@"http://itunes.apple.com/lookup"];
        [requestUrlString appendFormat:@"?bundleId=%@", bundleString];
        if (countryCode)
        {
            [requestUrlString appendFormat:@"&country=%@", countryCode];
        }
        NSURL *requestURL = [[NSURL alloc] initWithString:requestUrlString];
        
        NSError *requestError;
        NSDictionary *jsonObject = [self resultsDictionaryForURL:requestURL error:&requestError];
        if (requestError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block)
                {
                    block(FALSE, requestError);
                }
            });
        }
        else
        {
            NSDictionary *appsDictionary = jsonObject;
            NSArray *results = [appsDictionary objectForKey:@"results"];
            NSString *pageTitle = @"Results";
            
            NSMutableArray *mutableApps = [[NSMutableArray alloc] init];
            for (NSDictionary *result in results)
            {
                DAAppObject *appObject = [[DAAppObject alloc] init];
                
                appObject.bundleId = [result objectForKey:@"bundleId"];
                appObject.name = [result objectForKey:@"trackName"];
                appObject.genre = [result objectForKey:@"primaryGenreName"];
                appObject.appId = [[result objectForKey:@"trackId"] integerValue];
                
                NSArray *features = [result objectForKey:@"features"];
                appObject.isUniversal = [features containsObject:@"iosUniversal"];
                appObject.formattedPrice = [[result objectForKey:@"formattedPrice"] uppercaseString];
                //NSString *iconUrlString = [result objectForKey:@"artworkUrl60"];
                NSString *iconUrlString = [result objectForKey:@"artworkUrl512"];
                NSArray *iconUrlComponents = [iconUrlString componentsSeparatedByString:@"."];
                NSMutableArray *mutableIconURLComponents = [[NSMutableArray alloc] initWithArray:iconUrlComponents];
                [mutableIconURLComponents insertObject:@"128x128-75" atIndex:mutableIconURLComponents.count-1];
                iconUrlString = [mutableIconURLComponents componentsJoinedByString:@"."];
                
                appObject.iconURL = [[NSURL alloc] initWithString:iconUrlString];
                appObject.userRating = [[result objectForKey:@"averageUserRating"] floatValue];
                appObject.userRatingCount = [[result objectForKey:@"userRatingCount"] integerValue];
                
                if (![mutableApps containsObject:appObject])
                {
                    [mutableApps addObject:appObject];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = pageTitle;
                self.appsArray = mutableApps;
                [self.tableView reloadData];
                if (block)
                {
                    block(TRUE, NULL);
                }
            });
        }
    });
}

- (void)loadAppsWithSearchTerm:(NSString *)searchTerm completionBlock:(void(^)(BOOL result, NSError *error))block
{
    self.title = NSLocalizedString(@"Loading...",);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        NSMutableString *requestUrlString = [[NSMutableString alloc] init];
        [requestUrlString appendFormat:@"http://itunes.apple.com/search"];
        [requestUrlString appendFormat:@"?term=%@", searchTerm];
        if (countryCode)
        {
            [requestUrlString appendFormat:@"&country=%@", countryCode];
        }
        [requestUrlString appendFormat:@"&entity=software"];
        NSURL *requestURL = [[NSURL alloc] initWithString:requestUrlString];
        
        NSError *requestError;
        NSDictionary *jsonObject = [self resultsDictionaryForURL:requestURL error:&requestError];
        if (requestError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block)
                {
                    block(FALSE, requestError);
                }
            });
        }
        else
        {
            NSDictionary *appsDictionary = jsonObject;
            NSArray *results = [appsDictionary objectForKey:@"results"];
            NSString *pageTitle = @"Results";
            
            NSMutableArray *mutableApps = [[NSMutableArray alloc] init];
            for (NSDictionary *result in results)
            {
                DAAppObject *appObject = [[DAAppObject alloc] init];
                
                appObject.bundleId = [result objectForKey:@"bundleId"];
                appObject.name = [result objectForKey:@"trackName"];
                appObject.genre = [result objectForKey:@"primaryGenreName"];
                appObject.appId = [[result objectForKey:@"trackId"] integerValue];
                
                NSArray *features = [result objectForKey:@"features"];
                appObject.isUniversal = [features containsObject:@"iosUniversal"];
                appObject.formattedPrice = [[result objectForKey:@"formattedPrice"] uppercaseString];
                //NSString *iconUrlString = [result objectForKey:@"artworkUrl60"];
                NSString *iconUrlString = [result objectForKey:@"artworkUrl512"];
                NSArray *iconUrlComponents = [iconUrlString componentsSeparatedByString:@"."];
                NSMutableArray *mutableIconURLComponents = [[NSMutableArray alloc] initWithArray:iconUrlComponents];
                [mutableIconURLComponents insertObject:@"128x128-75" atIndex:mutableIconURLComponents.count-1];
                iconUrlString = [mutableIconURLComponents componentsJoinedByString:@"."];
                
                appObject.iconURL = [[NSURL alloc] initWithString:iconUrlString];
                appObject.userRating = [[result objectForKey:@"averageUserRating"] floatValue];
                appObject.userRatingCount = [[result objectForKey:@"userRatingCount"] integerValue];
                
                if (![mutableApps containsObject:appObject])
                {
                    [mutableApps addObject:appObject];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = pageTitle;
                self.appsArray = mutableApps;
                [self.tableView reloadData];
                if (block)
                {
                    block(TRUE, NULL);
                }
            });
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appsArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = (indexPath.row % 2 ? DARK_BACKGROUND_COLOR : LIGHT_BACKGROUND_COLOR);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DAAppViewCell *cell = (DAAppViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[DAAppViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.appObject = [self.appsArray objectAtIndex:indexPath.row];
    
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
    DAAppObject *appObject = [self.appsArray objectAtIndex:indexPath.row];
    
    if (self.didViewAppBlock)
    {
        self.didViewAppBlock(appObject.appId);
    }
    
    if ([SKStoreProductViewController class])
    {
        NSDictionary *appParameters = @{SKStoreProductParameterITunesItemIdentifier : [NSString stringWithFormat:@"%u", appObject.appId]};
        SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
        [productViewController setDelegate:self];
        [productViewController loadProductWithParameters:appParameters completionBlock:nil];
        [self presentViewController:productViewController
                           animated:YES
                         completion:nil];
    }
    else
    {
        NSString *appUrlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%u?mt=8", appObject.appId];
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
