//
//  GAPluginsViewController.m
//  GremlinApp
//
//  Created by Youssef Francis on 10/9/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import "GAPluginsListViewController.h"
#import <Gremlin/GRPluginScanner.h>

@interface GAPluginsListViewController ()

@end

@implementation GAPluginsListViewController
@synthesize plugins;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Plugins";//NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"Plugins"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.plugins = [GRPluginScanner allAvailableDestinations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.plugins = nil;
    [super dealloc];
}

#pragma mark - Table view data source

- (NSString*)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Available Plugins", @"Available Plugins");
}

- (NSString*)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section
{
    return @"This is the list of plugins installed on your device "
           @"that are supported on your version of iOS";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return plugins.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellId = @"PluginCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellId] autorelease];
    }
    
    GRDestination* plugin = [plugins objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [plugin description];
    cell.detailTextLabel.text = plugin.name;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
