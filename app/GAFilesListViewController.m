//
//  PSTableViewController.m
//  PSFilePickerController
//
//  Created by Josh Kugelmann on 18/08/12.
//  Copyright (c) 2012 Josh Kugelmann. All rights reserved.
//

#import "GAFilesListViewController.h"
#import "GAFilesViewController.h"
#import "GAFilesEntry.h"

@implementation GAFilesListViewController

@synthesize path = _path;
@synthesize files = _files;

- (GAFilesListViewController *)initWithDirectoryAtPath:(NSString *)aPath
{
    self = [super init];
    
    if (self) {
        _path = [aPath copy];
        [self rebuildFileList];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the prompt text
    [[self navigationItem] setPrompt:[(GAFilesViewController *)[self navigationController] prompt]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_files release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [_path release];
    
    [super dealloc];
}

- (NSString *)title
{
    return [[self path] lastPathComponent];
}

- (void)rebuildFileList
{
    NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:nil];
    NSMutableArray *visibleFiles = [NSMutableArray arrayWithCapacity:[allFiles count]];
    
    for (NSString *file in allFiles) {
        if (![file hasPrefix:@"."]) {
            NSString *fullPath = [[self path] stringByAppendingPathComponent:file];
            BOOL isDir = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
            
            GAFilesEntry *entry = [[GAFilesEntry alloc] initWithPath:fullPath name:file dir:isDir];
            [visibleFiles addObject:entry];
            [entry release];
        }
    }

    [self setFiles:visibleFiles];
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *newFolderPath = [[self path] stringByAppendingPathComponent:[[alertView textFieldAtIndex:0] text]];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        [self rebuildFileList];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self files] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GAFilesEntry *entry = [[self files] objectAtIndex:[indexPath row]];

    if ([entry isDir])
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//    else
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    
//    [[cell textLabel] setEnabled:[entry isDir]];
    [[cell textLabel] setText:[entry name]];
        
    
    return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GAFilesEntry *entry = [[self files] objectAtIndex:[indexPath row]];
    
    if ([entry isDir])
        return indexPath;
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GAFilesEntry *entry = [[self files] objectAtIndex:[indexPath row]];
    GAFilesListViewController *detailViewController = [[GAFilesListViewController alloc] initWithDirectoryAtPath:[entry path]];

    [[self navigationController] pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

@end
