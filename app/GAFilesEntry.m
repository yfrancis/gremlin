//
//  PSDirectoryPickerEntry.m
//  PSFilePickerController
//
//  Created by Josh Kugelmann on 25/08/12.
//  Copyright (c) 2012 Josh Kugelmann. All rights reserved.
//

#import "GAFilesEntry.h"

@implementation GAFilesEntry

@synthesize path = _path;
@synthesize name = _name;
@synthesize dir = _dir;

- (GAFilesEntry *)initWithPath:(NSString *)path name:(NSString *)name dir:(BOOL)dir
{
    self = [super init];
    
    if (self) {
        _path = [path copy];
        _name = [name copy];
        _dir = dir;
    }
    
    return self;
}

- (void)dealloc
{
    [_path release];
    [_name release];
    
    [super dealloc];
}

@end
