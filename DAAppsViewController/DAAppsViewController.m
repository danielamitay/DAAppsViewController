//
//  DAAppsViewController.m
//  DAAppsViewController
//
//  Created by Daniel Amitay on 4/3/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import "DAAppsViewController.h"
#import <StoreKit/StoreKit.h>
#import "DAAppsViewCell.h"

#define DARK_BACKGROUND_COLOR   [UIColor colorWithWhite:235.0f/255.0f alpha:1.0f]
#define LIGHT_BACKGROUND_COLOR  [UIColor colorWithWhite:245.0f/255.0f alpha:1.0f]

@interface DAAppsViewController ()

@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSArray *appsArray;

@end

@implementation DAAppsViewController

#pragma mark - Property methods

- (void)setArtistId:(NSInteger)artistId
{
    _artistId = artistId;
    if (_urlConnection)
    {
        [_urlConnection cancel];
        _responseData = nil;
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
    _urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    self.title = NSLocalizedString(@"Loading...",);
}

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - URL connection delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.title = NSLocalizedString(@"Error",);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.tableView reloadData];
}

@end
