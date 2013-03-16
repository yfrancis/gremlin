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
#import <Gremlin/Gremlin.h>

#define GRLocalizedString(x) NSLocalizedString(x, x)

static inline NSString* GR_GET_STRING_FOR_MEDIAKIND(NSString* mediaKind)
{
    return [[GRImportViewController humanizedMediaKinds] objectForKey:mediaKind];
}

static inline BOOL GR_IS_IPAD()
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

static id GR_GET_DICT_VAL(NSDictionary* dict, NSString* key)
{
    id val = [dict objectForKey:key];
    if(val)
    {
        return [val retain];
    }

    return nil;
}

@interface UIImage (ImageScale)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end

@implementation UIImage (ImageScale)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIScreen* screen = [UIScreen mainScreen];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, screen.scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

@end

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
    NSMutableDictionary* _cells;
    NSIndexPath* _savedIndex;
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

        _cells = [NSMutableDictionary new];
        NSDictionary* metadata = [_importDict objectForKey:@"metadata"];
        if(!metadata)
        {
            [_importDict setObject:[NSMutableDictionary new] forKey:@"metadata"];
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

    static NSString* CellIdentifier = @"Cell";
    NSMutableArray* cells = nil;
    GREditableImportTableViewCell* cell = nil;

    NSDictionary* metadata = [_importDict objectForKey:@"metadata"];

    // song.
    cells = [NSMutableArray new];
    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"title");
    cell.textField.placeholder = GRLocalizedString(@"An awesome title.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"title");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"artist");
    cell.textField.placeholder = GRLocalizedString(@"An awesome artist.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"artist");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"album");
    cell.textField.placeholder = GRLocalizedString(@"An awesome album.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"album");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"genre");
    cell.textField.placeholder = GRLocalizedString(@"An awesome genre.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"genre");
    [cells addObject:cell];
    
    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"year");
    cell.textField.placeholder = @"2013";
    cell.textField.text = [GR_GET_DICT_VAL(metadata, @"year") stringValue];
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    [cells addObject:cell];
    [_cells setObject:cells forKey:@"song"];
    [_cells setObject:cells forKey:@"music-video"];

    // podcast, videoPodcast
    cells = [NSMutableArray new];
    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"title");
    cell.textField.placeholder = GRLocalizedString(@"An awesome title.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"title");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"name");
    cell.textField.placeholder = GRLocalizedString(@"An awesome podcast name.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"podcastName");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"episode");
    cell.textField.placeholder = @"1";
    cell.textField.text = [GR_GET_DICT_VAL(metadata, @"episode") stringValue];
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"genre");
    cell.textField.placeholder = GRLocalizedString(@"An awesome genre.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"genre");
    [cells addObject:cell];
    
    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"year");
    cell.textField.placeholder = @"2013";
    cell.textField.text = [GR_GET_DICT_VAL(metadata, @"year") stringValue];
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    [cells addObject:cell];
    [_cells setObject:cells forKey:@"podcast"];
    [_cells setObject:cells forKey:@"videoPodcast"];

    // tv-episode.
    cells = [NSMutableArray new];
    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"title");
    cell.textField.placeholder = GRLocalizedString(@"An awesome title.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"title");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"series");
    cell.textField.placeholder = GRLocalizedString(@"An awesome series name.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"series");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"season");
    cell.textField.placeholder = @"1";
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"season");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"episode");
    cell.textField.placeholder = @"1";
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"episode");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"year");
    cell.textField.placeholder = @"2013";
    cell.textField.text = [GR_GET_DICT_VAL(metadata, @"year") stringValue];
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    [cells addObject:cell];
    [_cells setObject:cells forKey:@"tv-episode"];

    // feature-movie.
    cells = [NSMutableArray new];
    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"title");
    cell.textField.placeholder = GRLocalizedString(@"An awesome title.");
    cell.textField.text = GR_GET_DICT_VAL(metadata, @"title");
    [cells addObject:cell];

    cell = [[GREditableImportTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = GRLocalizedString(@"year");
    cell.textField.placeholder = @"2013";
    cell.textField.text = [GR_GET_DICT_VAL(metadata, @"year") stringValue];
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    [cells addObject:cell];
    [_cells setObject:cells forKey:@"feature-movie"];

    NSDictionary* kinds = [GRImportViewController humanizedMediaKinds];
    for(NSString* kind in [kinds allKeys])
    {
        for(GREditableImportTableViewCell* cell in [_cells objectForKey:kind])
        {
            cell.textField.hidden = NO;
            cell.detailTextLabel.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _existingStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:_existingStatusBarStyle animated:YES];
}

- (void)_cancelJob:(id)sender
{
    if (self.completionBlock)
        self.completionBlock(YES);
}

- (void)_finishImporting:(id)sender
{
    [Gremlin registerNotifications:self];
    [Gremlin importFileWithInfo:_importDict];
}

- (void)gremlinImportWasSuccessful:(NSDictionary*)info
{
    if (self.completionBlock)
        self.completionBlock(NO);
}

- (void)gremlinImport:(NSDictionary*)info didFailWithError:(NSError*)error
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Import Failed" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
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
        NSString* mediaKind = [_importDict objectForKey:@"mediaKind"];
        NSMutableArray* cells = [_cells objectForKey:mediaKind];
        return cells.count;
    }
    else if(section == 3)
    {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* ArtworkIdentifier = @"ArtworkCell";
    static NSString* KindIdentifier = @"KindCell";

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
            cell.imageView.image = [UIImage imageWithImage:[UIImage imageWithData:[[_importDict objectForKey:@"metadata"] objectForKey:@"imageData"]] scaledToSize:CGSizeMake(72.f, 72.f)];
            cell.textLabel.text = GRLocalizedString(@"Cover Art");
            cell.detailTextLabel.text = GRLocalizedString(@"Tap to change.");
        }
                
        return cell;
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KindIdentifier];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:KindIdentifier];
        }
        
        cell.textLabel.text = GRLocalizedString(@"kind");
        cell.detailTextLabel.text = GR_GET_STRING_FOR_MEDIAKIND([_importDict objectForKey:@"mediaKind"]);
                
        return cell;
    }
    else
    {
        NSString* mediaKind = [_importDict objectForKey:@"mediaKind"];
        NSMutableArray* cells = [_cells objectForKey:mediaKind];
        return [cells objectAtIndex:indexPath.row];
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

        if (GR_IS_IPAD())
        {
            UIPopoverController* popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
            CGRect rect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:indexPath] toView:tableView]; 
            popoverController.delegate = self;
            _savedIndex = indexPath;
            [popoverController presentPopoverFromRect:rect inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
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

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(_savedIndex)
    {
        [self.tableView deselectRowAtIndexPath:_savedIndex animated:YES];
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
    [[_importDict objectForKey:@"metadata"] setObject:UIImageJPEGRepresentation(originalImage, 1.0f) forKey:@"imageData"];
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
