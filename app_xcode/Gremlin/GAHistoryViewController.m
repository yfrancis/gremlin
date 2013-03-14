//
//  GAActivityViewController.m
//  Gremlin
//
//  Created by Ian on 11/1/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import "GAHistoryViewController.h"
#import "GAActivityTableViewCell.h"
#import <Gremlin/Gremlin.h>
#import <Gremlin/GRTask.h>

#import <Gremlin/AppSupport/CPDistributedMessagingCenter.h>

#import <AVFoundation/AVFoundation.h>

#define LGRAYCOLOR [UIColor lightGrayColor]
#define ERRCOLOR [UIColor redColor]

@interface GAHistoryViewController ()

@end

@implementation GAHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"History";//NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"history"];
        
        history = nil;
        
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
- (void)update
{
    if (history) [history release];
    history = [[Gremlin getHistory] retain];
    [self.tableView reloadData];
}
- (void)manifestTasksUpdated:(NSArray*)tasks
{
    [self update];
}

- (void)didBecomeActive
{
    [self update];
}
- (void)didResignActive
{
    [history release];
    history = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self update];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"History";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GAActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BDCustomCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GAActivityTableViewCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        
        GRTask *task = [history objectAtIndex:indexPath.row];
        [task retain];
        
        BOOL bStatus = YES;
        NSDictionary *metadata = task.metadata;
        //NSDictionary *info = [task info];
        NSNumber *status = task.status;
        if (status) bStatus = [status boolValue];
        NSString *error = task.error;
        NSString *title = [metadata objectForKey:@"title"];
        NSString *destination = task.destination;
        NSString *path = task.path;
        NSString *kind = [importKindDictionary objectForKey:task.mediaKind];
        NSData *imageData = [metadata objectForKey:@"imageData"];
        UIImage *image;
        
        if (title == nil) {
            title = [[path lastPathComponent] stringByDeletingPathExtension];
        }
        
        if (imageData) {
            image = [UIImage imageWithData:imageData];
            cell.iconView.image = image;
        }
        else {
            image = [iconDictionary objectForKey:task.mediaKind];
            if (image)
                cell.iconView.image = image;
        }
        
        NSString *destinationLabelText;
        if (bStatus) {
            if(destination)
                destinationLabelText = [NSString stringWithFormat:@"Imported into: %@", destination];
            else
                destinationLabelText = @"Imported";
        }
        else {
            cell.destinationLabel.textColor = ERRCOLOR;
            destinationLabelText = [NSString stringWithFormat:@"Error: %@", (error ? error : @"Unknown")];
        }
        
        cell.titleLabel.text = title;
        cell.kindLabel.text = kind;
        cell.inProgress = NO;
        cell.destinationLabel.text = destinationLabelText;
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
    if (history) [history release];
    [importKindDictionary release];
    [iconDictionary release];
    [super dealloc];
}
@end
