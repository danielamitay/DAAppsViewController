//
//  RootViewController.m
//  DAAppsViewControllerExample
//
//  Created by Daniel Amitay on 7/18/23.
//

#import "RootViewController.h"

#import "DAAppsViewController.h"

@interface RootViewController ()

@property (nonatomic, copy) NSDictionary *artistsDictionary;
@property (nonatomic, copy) NSDictionary *appsDictionary;
@property (nonatomic, copy) NSDictionary *termsDictionary;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 44.0f;
    self.title = @"DAAppsViewController";

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    self.artistsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              @356087517, @"Daniel Amitay",
                              @284417353, @"Apple",
                              @284882218, @"Facebook",
                              @281956209, @"Google",
                              nil];

    self.appsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                           @[@447188370, @835599320, @333903271,@6446901002,@284882215,@389801252,@288429040,@310633997], @"Social Apps",
                           @[@401626263, @363590051, @963034692, @498151501,@582790430,@493136154], @"Slick Apps",
                           @[@284993459,@383463868,@377342622,@489321253], @"Cool Tech",
                           nil];

    self.termsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"Angry", @"Angry",
                            @"Sleep", @"Sleep",
                            @"Radio", @"Radio",
                            nil];
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"By Artist Identifier (NSInteger)";
        case 1:
            return @"By App Identifiers (NSArray)";
        case 2:
            return @"By Search Term (NSString) + Modal Presentation";
        default:
            return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.artistsDictionary.allKeys.count;
        case 1:
            return self.appsDictionary.allKeys.count;
        case 2:
            return self.termsDictionary.allKeys.count;
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    switch (indexPath.section) {
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
    switch (indexPath.section) {
        case 0: {
            NSString *key = [self.artistsDictionary.allKeys objectAtIndex:indexPath.row];
            NSNumber *number = [self.artistsDictionary objectForKey:key];
            DAAppsViewController *appsViewController = [[DAAppsViewController alloc] init];
            [appsViewController loadAppsWithArtistId:number.integerValue completionBlock:nil];
            [self.navigationController pushViewController:appsViewController animated:YES];
        } break;
        case 1: {
            NSString *key = [self.appsDictionary.allKeys objectAtIndex:indexPath.row];
            NSArray *values = [self.appsDictionary objectForKey:key];
            DAAppsViewController *appsViewController = [[DAAppsViewController alloc] init];
            appsViewController.pageTitle = key;
            [appsViewController loadAppsWithAppIds:values completionBlock:nil];
            [self.navigationController pushViewController:appsViewController animated:YES];
        } break;
        case 2: {
            NSString *key = [self.termsDictionary.allKeys objectAtIndex:indexPath.row];
            NSString *term = [self.termsDictionary objectForKey:key];
            DAAppsViewController *appsViewController = [[DAAppsViewController alloc] init];
            [appsViewController loadAppsWithSearchTerm:term completionBlock:nil];
            UINavigationController *modalNavController = [[UINavigationController alloc] init];
            appsViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                                   style:UIBarButtonItemStyleDone
                                                                                                  target:self
                                                                                                  action:@selector(dismissModal)];
            [modalNavController setViewControllers:@[appsViewController]];
            modalNavController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:modalNavController animated:YES completion:nil];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } break;
        default:
            break;
    }
}

- (void)dismissModal
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
