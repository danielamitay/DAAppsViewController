//
//  RootViewController.m
//  DAAppsViewControllerExample
//
//  Created by Daniel Amitay on 4/9/13.
//  Copyright (c) 2013 Daniel Amitay. All rights reserved.
//

#import "RootViewController.h"

#import "DAAppsViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) NSDictionary *artistsDictionary;
@property (nonatomic, strong) NSDictionary *appsDictionary;
@property (nonatomic, strong) NSDictionary *termsDictionary;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 44.0f;
    self.title = @"DAAppsViewController";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
    self.artistsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              @356087517, @"Daniel Amitay",
                              @284417353, @"Apple",
                              @284882218, @"Facebook",
                              @281956209, @"Google",
                              nil];
    
    self.appsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                           @[@592447445,@333903271,@284882215,@288429040,@403639508,@310633997], @"Social Apps",
                           @[@575647534,@498151501,@482453112,@582790430,@543421080,@493136154], @"Slick Apps",
                           @[@284993459,@383463868,@377342622,@489321253], @"Cool Tech",
                           nil];
    
    self.termsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"Angry", @"Angry",
                            @"Sleep", @"Sleep",
                            @"Radio", @"Radio",
                            nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"By Artist Identifier (NSInteger)";
            break;
        case 1:
            return @"By App Identifiers (NSArray)";
            break;
        case 2:
            return @"By Search Term (NSString)";
            break;
        default:
            return nil;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return self.artistsDictionary.allKeys.count;
            break;
        case 1:
            return self.appsDictionary.allKeys.count;
            break;
        case 2:
            return self.termsDictionary.allKeys.count;
            break;
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.text = [self.artistsDictionary.allKeys objectAtIndex:indexPath.row];
            break;
        case 1:
            cell.textLabel.text = [self.appsDictionary.allKeys objectAtIndex:indexPath.row];
            break;
        case 2:
            cell.textLabel.text = [self.termsDictionary.allKeys objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAAppsViewController *appsViewController = [[DAAppsViewController alloc] init];
    switch (indexPath.section)
    {
        case 0:
        {
            NSString *key = [self.artistsDictionary.allKeys objectAtIndex:indexPath.row];
            NSNumber *number = [self.artistsDictionary objectForKey:key];
            [appsViewController loadAppsWithArtistId:number.integerValue completionBlock:nil];
        }
            break;
        case 1:
        {
            NSString *key = [self.appsDictionary.allKeys objectAtIndex:indexPath.row];
            NSArray *values = [self.appsDictionary objectForKey:key];
            appsViewController.pageTitle = key;
            [appsViewController loadAppsWithAppIds:values completionBlock:nil];
        }
            break;
        case 2:
        {
            NSString *key = [self.termsDictionary.allKeys objectAtIndex:indexPath.row];
            NSString *term = [self.termsDictionary objectForKey:key];
            [appsViewController loadAppsWithSearchTerm:term completionBlock:nil];
        }
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:appsViewController animated:YES];
}

@end
