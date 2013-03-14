//
//  GRImportViewController.m
//  Gremlin
//
//  Created by Nicolas Haunold on 3/8/13.
//  Copyright (c) 2013 Nicolas Haunold. All rights reserved.
//

#import "GRImportViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#define GRLocalizedString(x) NSLocalizedString(x, x)

static inline NSString* GR_GET_STRING_FOR_MEDIAKIND(NSString* mediaKind)
{
    return [[GRImportViewController humanizedMediaKinds] objectForKey:mediaKind];
}

@interface GREditableImportTableViewCell : UITableViewCell

@property (nonatomic, strong) UITextField* textField;

@end

@implementation GREditableImportTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.textField];
        self.detailTextLabel.hidden = YES;
    }

    return self;
}

- (void)layoutSubviews
{
    if(!self.detailTextLabel.text)
    {
        self.detailTextLabel.text = @"hello";
    }
    [super layoutSubviews];

    self.textField.frame = self.detailTextLabel.frame;
    self.textField.frame = CGRectMake(self.detailTextLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, self.contentView.frame.size.width - self.detailTextLabel.frame.origin.x - 15, self.textField.frame.size.height);
    self.textField.textColor = self.detailTextLabel.textColor;
    self.textField.font = self.detailTextLabel.font;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
}

@end

@implementation GRImportViewController
{
    NSMutableDictionary* _importDict;
    UIStatusBarStyle _existingStatusBarStyle;
}

+ (NSDictionary*)humanizedMediaKinds
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
        @"Song", @"song",
				@"Music Video", @"music-video",
				@"Podcast", @"podcast",
				@"Movie", @"feature-movie",
        @"TV Episode", @"tv-episode",
        @"Video Podcast", @"videoPodcast",
				nil
		];
}

- (id)initWithDictionary:(NSDictionary*)importDict completion:(GRImportViewControllerCompletionBlock)completion
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self)
    {
        _importDict = [importDict mutableCopy];
        if(![_importDict objectForKey:@"mediaKind"])
        {
            // Set default value.
            [_importDict setObject:@"song" forKey:@"mediaKind"];
        }
        
        self.completionBlock = completion;
        self.showKindSelector = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Import Media";

    UIBarButtonItem* cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancelJob:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;

    UIBarButtonItem* doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_finishImporting:)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _existingStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:_existingStatusBarStyle animated:YES];
}

- (void)_cancelJob:(id)sender
{
    if (self.completionBlock)
        self.completionBlock(YES);
}

- (void)_finishImporting:(id)sender
{
    if (self.completionBlock)
        self.completionBlock(NO);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 1;
    }
    else if(section == 2)
    {
        return 5;
    }
    else if(section == 3)
    {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    static NSString* ArtworkIdentifier = @"ArtworkCell";
    
    if(indexPath.section == 0 || indexPath.section == 3)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ArtworkIdentifier];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ArtworkIdentifier];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if(indexPath.section == 0)
        {
            cell.textLabel.text = GRLocalizedString(@"Preview Media");
        }
        else if(indexPath.section == 3)
        {
            cell.textLabel.text = GRLocalizedString(@"Cover Art");
            cell.detailTextLabel.text = GRLocalizedString(@"Tap to change.");
        }
                
        return cell;
    }
    else
    {
        GREditableImportTableViewCell *cell = (GREditableImportTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        }
        
        
        NSString* mediaKind = [_importDict objectForKey:@"mediaKind"];

        cell.textField.delegate = self;
        if(self.showKindSelector)
        {
            if(indexPath.section == 1)
            {
                cell.textLabel.text = @"kind";
                cell.detailTextLabel.hidden = NO;
                cell.textField.hidden = YES;
                cell.detailTextLabel.text = GR_GET_STRING_FOR_MEDIAKIND([_importDict objectForKey:@"mediaKind"]);
            }
            else if(indexPath.section == 2)
            {
                cell.textField.hidden = NO;
                cell.detailTextLabel.hidden = YES;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                if(indexPath.row == 0)
                {
                    cell.textLabel.text = @"title";
                    cell.textField.placeholder = @"An awesome title.";
                }
                else if(indexPath.row == 1)
                {
                    cell.textLabel.text = @"artist";
                    cell.textField.placeholder = @"An awesome artist.";
                    if([mediaKind isEqualToString:@"tv-episode"])
                    {
                        cell.textLabel.text = @"series";
                        cell.textField.placeholder = @"An awesome series.";
                    }
                    
                }
                else if(indexPath.row == 2)
                {
                    cell.textField.placeholder = @"An awesome album.";
                    if([mediaKind isEqualToString:@"song"] || [mediaKind isEqualToString:@"music-video"])
                    {
                        cell.textLabel.text = @"album";
                    }
                    else if([mediaKind isEqualToString:@"tv-episode"])
                    {
                        cell.textLabel.text = @"season";
                        cell.textField.placeholder = @"1";
                        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                        cell.textField.placeholder = @"An awesome season.";
                    }
                    else if([mediaKind isEqualToString:@"podcast"] || [mediaKind isEqualToString:@"videoPodcast"])
                    {
                        cell.textLabel.text = @"episode";
                        cell.textField.placeholder = @"1";
                        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                        cell.textField.placeholder = @"An awesome episode.";
                    }
                    else
                    {
                        cell.textLabel.text = @"collection";
                        cell.textField.placeholder = @"An awesome collection.";
                    }
                }
                else if(indexPath.row == 3)
                {
                    cell.textLabel.text = @"genre";
                    cell.textField.placeholder = @"An awesome genre.";
                    if([mediaKind isEqualToString:@"tv-episode"])
                    {
                        cell.textLabel.text = @"episode";
                        cell.textField.placeholder = @"1";
                        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                        cell.textField.placeholder = @"An awesome episode.";
                    }
                }
                else if(indexPath.row == 4)
                {
                    cell.textLabel.text = @"year";
                    cell.textField.placeholder = @"2013";
                    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                }
            }
        }
        else
        {
            if(indexPath.section == 2)
            {
            }
        }
        
        return cell;
    }
    
    return nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 3)
    {
        return 88.f;
    }
    
    return 48.f;
}

- (void)_showMediaKindPicker
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] init];
    NSDictionary* mediaKinds = [GRImportViewController humanizedMediaKinds];
    NSInteger buttonIndex = 0;
    
    for(NSString* key in [mediaKinds allKeys])
    {
        [actionSheet addButtonWithTitle:[mediaKinds objectForKey:key]];
        buttonIndex++;
    }
    
    [actionSheet setTag:0xFEEDCAFE];
    [actionSheet addButtonWithTitle:GRLocalizedString(@"Cancel")];
    [actionSheet setCancelButtonIndex:buttonIndex];
    [actionSheet setDelegate:self];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 0xFEEDCAFE && buttonIndex != [actionSheet cancelButtonIndex])
    {
        NSDictionary* humanizedMediaKinds = [GRImportViewController humanizedMediaKinds];
        NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

        NSString* mediaItem = [[humanizedMediaKinds allKeysForObject:buttonTitle] lastObject];
        [_importDict setObject:mediaItem forKey:@"mediaKind"];
    }

    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        NSString* filePath = [_importDict objectForKey:@"path"];
        MPMoviePlayerViewController* moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
        moviePlayer.moviePlayer.shouldAutoplay = YES;
        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    }
    else if(indexPath.section == 3)
    {
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;

        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else if(indexPath.section == 1)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

        if(self.showKindSelector)
        {
            [self _showMediaKindPicker];
        }
    }
}

- (void)textDidChange:(id)sender
{
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage* originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_importDict setObject:UIImageJPEGRepresentation(originalImage, 1.0f) forKey:@"imageData"];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


@end
