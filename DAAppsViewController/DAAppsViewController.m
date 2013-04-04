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
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
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
    DAAppsViewCell *cell = (DAAppsViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[DAAppsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSMutableDictionary *appDictionary = [self.appsArray objectAtIndex:indexPath.row];
    
    cell.name = [appDictionary objectForKey:@"name"];
    cell.genre = [appDictionary objectForKey:@"genre"];
    cell.appId = [[appDictionary objectForKey:@"appId"] integerValue];
    cell.userRatingCount = [[appDictionary objectForKey:@"userRatingCount"] integerValue];
    cell.userRating = [[appDictionary objectForKey:@"userRating"] floatValue];
    cell.buttonText = [appDictionary objectForKey:@"buttonText"];
    
    UIImage *iconImage = [appDictionary objectForKey:@"iconImage"];
    if (iconImage)
    {
        cell.icon = iconImage;
    }
    else
    {
        cell.icon = [UIImage imageNamed:@"DAPlaceholderImage"];
        NSString *iconUrlString = [appDictionary objectForKey:@"iconUrlString"];
        NSURL *iconURL = [[NSURL alloc] initWithString:iconUrlString];
        dispatch_queue_t thread = dispatch_queue_create(NULL, NULL);
        dispatch_async(thread, ^{
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
            [urlRequest setURL:iconURL];
            [urlRequest setTimeoutInterval:10.0f];
            [urlRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
            NSData *iconData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                     returningResponse:NULL
                                                                 error:NULL];
            UIImage *iconImage = [UIImage imageWithData:iconData];
            
            BOOL iconIsPrerendered = [[appDictionary objectForKey:@"iconIsPrerendered"] boolValue];
            if (!iconIsPrerendered)
            {
                UIGraphicsBeginImageContext(iconImage.size);
                [iconImage drawAtPoint:CGPointZero];
                CGRect imageRect = (CGRect) {
                    .size = iconImage.size
                };
                [[UIImage imageNamed:@"DAOverlayImage"] drawInRect:imageRect];
                iconImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            CGImageRef maskRef = [UIImage imageNamed:@"DAMaskImage"].CGImage;
            CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                                CGImageGetHeight(maskRef),
                                                CGImageGetBitsPerComponent(maskRef),
                                                CGImageGetBitsPerPixel(maskRef),
                                                CGImageGetBytesPerRow(maskRef),
                                                CGImageGetDataProvider(maskRef), NULL, false);
            CGImageRef maskedImageRef = CGImageCreateWithMask([iconImage CGImage], mask);
            iconImage = [UIImage imageWithCGImage:maskedImageRef];
            CGImageRelease(mask);
            CGImageRelease(maskedImageRef);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [appDictionary setObject:iconImage forKey:@"iconImage"];
                if (cell == [tableView cellForRowAtIndexPath:indexPath])
                {
                    cell.icon = iconImage;
                }
            });
        });
        #if !OS_OBJECT_USE_OBJC
        dispatch_release(thread);
        #endif
    }
    
    return cell;
}

#pragma mark - URL connection delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.title = NSLocalizedString(@"Error",);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *artistDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                                     options:0
                                                                       error:NULL];
    
    self.title = [artistDictionary objectForKey:@"pageTitle"];
    
    NSMutableArray *mutableAppsArray = [[NSMutableArray alloc] init];
    NSArray *stack = [artistDictionary objectForKey:@"stack"];
    for (NSDictionary *swoosh in stack)
    {
        NSString *title = [swoosh objectForKey:@"title"];
        NSArray *content = [swoosh objectForKey:@"content"];
        for (NSDictionary *lockup in content)
        {
            NSMutableDictionary *appDictionary = [[NSMutableDictionary alloc] init];
            
            NSString *bundleId = [lockup objectForKey:@"bundle-id"];
            [appDictionary setObject:bundleId forKey:@"bundleId"];
            
            NSString *name = [lockup objectForKey:@"name"];
            [appDictionary setObject:name forKey:@"name"];
            
            NSString *genre = [lockup objectForKey:@"genre"];
            [appDictionary setObject:genre forKey:@"genre"];
            
            NSNumber *appNumber = [lockup objectForKey:@"id"];
            [appDictionary setObject:appNumber forKey:@"appId"];
            
            NSString *minimumOSVersion = [lockup objectForKey:@"minimum-os-version"];
            [appDictionary setObject:minimumOSVersion forKey:@"minimumOSVersion"];
            
            NSNumber *iconPrerenderedNumber = [lockup objectForKey:@"icon-is-prerendered"];
            if (iconPrerenderedNumber)
            {
                [appDictionary setObject:iconPrerenderedNumber forKey:@"iconIsPrerendered"];
            }
            
            NSNumber *isUniversalNumber = [lockup objectForKey:@"is_universal_app"];
            if (isUniversalNumber)
            {
                [appDictionary setObject:isUniversalNumber forKey:@"isUniversalApp"];
            }
            
            NSArray *offers = [lockup objectForKey:@"offers"];
            NSDictionary *offer = [offers lastObject];
            NSString *buttonText = [offer objectForKey:@"button_text"];
            [appDictionary setObject:buttonText forKey:@"buttonText"];
            
            NSArray *artwork = [lockup objectForKey:@"artwork"];
            int scale = (int)[[UIScreen mainScreen] scale];
            NSDictionary *artworkDictionary = [artwork objectAtIndex:MIN(artwork.count, (scale*2)-2)];
            NSString *iconUrl = [artworkDictionary objectForKey:@"url"];
            [appDictionary setObject:iconUrl forKey:@"iconUrlString"];
            
            NSNumber *userRatingNumber = [lockup objectForKey:@"user_rating"];
            if (userRatingNumber)
            {
                [appDictionary setObject:userRatingNumber forKey:@"userRating"];
            }
            
            NSNumber *userRatingCountNumber = [lockup objectForKey:@"user_rating_count"];
            if (userRatingCountNumber)
            {
                [appDictionary setObject:userRatingCountNumber forKey:@"userRatingCount"];
            }
            
            BOOL sameBundle = [bundleId isEqualToString:[[NSBundle mainBundle] bundleIdentifier]];
            BOOL rejectBecauseSame = (self.onlyShowOtherApps && sameBundle);
            BOOL isPad = (UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom]);
            BOOL appIsPad = ([title rangeOfString:@"iPad"].length == @"iPad".length);
            BOOL systemVersionTooLow = ([minimumOSVersion compare:[[UIDevice currentDevice] systemVersion]
                                                          options:NSNumericSearch] == NSOrderedDescending);
            BOOL rejectBecauseIncompatible = (self.onlyShowCompatibleApps
                                              && ((appIsPad && !isPad) || systemVersionTooLow));
            if (![mutableAppsArray containsObject:appDictionary] &&
                !rejectBecauseIncompatible &&
                !rejectBecauseSame)
            {
                [mutableAppsArray addObject:appDictionary];
            }
        }
    }
    self.appsArray = mutableAppsArray;
    
    [self.tableView reloadData];
}

@end
