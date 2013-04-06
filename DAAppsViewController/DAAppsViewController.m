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

@interface DAAppsViewController () <NSURLConnectionDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSArray *appsArray;

- (NSDictionary *)resultsDictionaryForURL:(NSURL *)URL error:(NSError **)error;

@end

@implementation DAAppsViewController

#pragma mark - Shared Instance

+ (DAAppsViewController *)sharedInstance
{
    static dispatch_once_t pred;
    static DAAppsViewController *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[DAAppsViewController alloc] init];
    });
    return sharedInstance;
}

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
    [request setValue:@"iTunes-iPad/6.0 (6; 16GB; dt:73)" forHTTPHeaderField:@"User-Agent"];
    
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
                                                                   options:0
                                                                     error:&jsonError];
    *error = jsonError;
    return jsonDictionary;
}

- (void)loadAppsWithArtistId:(NSInteger)artistId completionBlock:(void(^)(BOOL result, NSError *error))block
{
    self.title = NSLocalizedString(@"Loading...",);
    
    dispatch_queue_t request_thread = dispatch_queue_create(NULL, NULL);
    dispatch_async(request_thread, ^{
        
    });
    #if !OS_OBJECT_USE_OBJC
    dispatch_release(retrieval_thread);
    #endif
}

- (void)loadAppsWithAppIds:(NSArray *)appIds completionBlock:(void(^)(BOOL result, NSError *error))block
{
    self.title = NSLocalizedString(@"Loading...",);
    
    dispatch_queue_t request_thread = dispatch_queue_create(NULL, NULL);
    dispatch_async(request_thread, ^{
        
    });
    #if !OS_OBJECT_USE_OBJC
    dispatch_release(retrieval_thread);
    #endif
}

- (void)loadAppsWithSearchTerm:(NSString *)searchTerm completionBlock:(void(^)(BOOL result, NSError *error))block
{
    self.title = NSLocalizedString(@"Loading...",);
    
    dispatch_queue_t request_thread = dispatch_queue_create(NULL, NULL);
    dispatch_async(request_thread, ^{
        
    });
    #if !OS_OBJECT_USE_OBJC
    dispatch_release(retrieval_thread);
    #endif
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appsArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *backgroundColor = (indexPath.row % 2 ? DARK_BACKGROUND_COLOR : LIGHT_BACKGROUND_COLOR);
    cell.contentView.backgroundColor = backgroundColor;
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

#pragma mark- Table view delegate methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DAAppObject *appObject = [self.appsArray objectAtIndex:indexPath.row];
    
    if (self.didViewApp)
    {
        self.didViewApp(appObject.appId);
    }
    
    if (NSClassFromString(@"SKStoreProductViewController"))
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrlString]];
    }
}

#pragma mark- Product view controller delegate methods

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
