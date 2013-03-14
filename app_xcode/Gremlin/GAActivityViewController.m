//
//  GAActivityViewController.m
//  Gremlin
//
//  Created by Ian on 11/1/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import "GAActivityViewController.h"
#import "GAActivityTableViewCell.h"
#import <Gremlin/Gremlin.h>
#import <Gremlin/GRTask.h>

#import <Gremlin/AppSupport/CPDistributedMessagingCenter.h>

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface GAActivityViewController ()

@end

@implementation GAActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Activity";
        self.tabBarItem.image = [UIImage imageNamed:@"Activity"];
    
        activeTasks = nil;
        
        importKindDictionary = @{
            @"song" : @"Song",
            @"ringtone" : @"Ringtone",
            @"podcast" : @"Podcast",
            @"video-podcast" : @"Podcast",
            @"music-video" : @"Video",
            @"feature-movie" : @"Movie",
            @"tv-episode" : @"TV Show",
        
            @"image" : @"Image",
            @"photo" : @"Photo",
            @"camera-photo" : @"Photo",
            @"camera-video" : @"Video",
            @"video" : @"Video",
            @"document" : @"Document"
        };
        [importKindDictionary retain];
        
        iconDictionary = @{
            @"song" : [UIImage imageNamed:@"itunes"],
            @"ringtone" : [UIImage imageNamed:@"itunes"],
            @"podcast" : [UIImage imageNamed:@"podcast"],
            @"video-podcast" : [UIImage imageNamed:@"podcast"],
            @"music-video" : [UIImage imageNamed:@"vidya"],
            @"feature-movie" : [UIImage imageNamed:@"vidya"],
            @"tv-episode" : [UIImage imageNamed:@"vidya"],
        
            @"image" : [UIImage imageNamed:@"image"],
            @"photo" : [UIImage imageNamed:@"image"],
            @"camera-photo" : [UIImage imageNamed:@"image"],
            @"camera-video" : [UIImage imageNamed:@"vidya"],
            @"video" : [UIImage imageNamed:@"vidya"]
        };
        [iconDictionary retain];
    }
    return self;
}
- (void)manifestTasksUpdated:(NSArray*)tasks
{
    BOOL hadOldCount = ([activeTasks count] || (activeTasks == nil) ? YES : NO);
    if (activeTasks) [activeTasks release];
    activeTasks = [tasks retain];
    self.tabBarItem.badgeValue = ([activeTasks count] ? [NSString stringWithFormat:@"%i", activeTasks.count] : nil);
    if (![activeTasks count] && hadOldCount) {
//        AudioServicesPlaySystemSound(1000);
    }
    [self.tableView reloadData];
}
- (void)manifestServerReset
{
    
}
- (void)didResignActive
{
    [activeTasks release];
    activeTasks = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Everything I do is perfect and we will never get a memory warning.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Activity";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (![activeTasks count]) {
        return @"There are currently no active tasks.";
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [activeTasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GAActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BDCustomCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GAActivityTableViewCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        
        GRTask *task = [activeTasks objectAtIndex:indexPath.row];
        [task retain];
        NSString *path = task.path;
        NSDictionary *metadata = task.metadata;
        
        NSString *title = [metadata objectForKey:@"title"];
        if (title == nil) {
            title = [[path lastPathComponent] stringByDeletingPathExtension];
        }
        NSData *imageData = [metadata objectForKey:@"imageData"];
        UIImage *image;
        if (imageData) {
            image = [UIImage imageWithData:imageData];
            cell.iconView.image = image;
        }
        else {
            image = [iconDictionary objectForKey:task.mediaKind];
            if (image)
                cell.iconView.image = image;
        }
        NSString *destination = task.destination;
        NSString *kind = [importKindDictionary objectForKey:task.mediaKind];
        
        cell.titleLabel.text = title;
        cell.kindLabel.text = kind;
        cell.inProgress = YES;
        NSString *destlabeltext;
        if(destination)
            destlabeltext = [NSString stringWithFormat:@"Importing into: %@…", destination];
        else
            destlabeltext = @"Importing…";
        cell.destinationLabel.text = destlabeltext;
        [task release];
    }
    
    return cell;
}
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
- (void)dealloc
{
    if (activeTasks) [activeTasks release];
    [importKindDictionary release];
    [iconDictionary release];
    [super dealloc];
}
@end
