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

@interface DAAppsViewController () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSArray *appsArray;

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

#pragma mark - Property methods

- (void)setArtistId:(NSInteger)artistId
{
    _artistId = artistId;
    if (self.urlConnection)
    {
        [self.urlConnection cancel];
        self.responseData = nil;
    }
    
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSMutableString *mutableRequestString = [[NSMutableString alloc] init];
    [mutableRequestString appendFormat:@"http://itunes.apple.com/%@/", countryCode];
    [mutableRequestString appendFormat:@"artist/id%i?dataOnly=true", _artistId];
    
    NSURL *requestURL = [[NSURL alloc] initWithString:mutableRequestString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:requestURL];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setCachePolicy:NSURLRequestReloadRevalidatingCacheData];
    [urlRequest setValue:@"iTunes-iPad/6.0 (6; 16GB; dt:73)" forHTTPHeaderField:@"User-Agent"];
    //self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    self.title = NSLocalizedString(@"Loading...",);
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
    
    return cell;
}

@end
