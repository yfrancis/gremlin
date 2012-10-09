//
//  PSDirectoryPickerEntry.h
//  PSFilePickerController
//
//  Created by Josh Kugelmann on 25/08/12.
//  Copyright (c) 2012 Josh Kugelmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAFilesEntry : NSObject {
    NSString *_path;
    NSString *_name;
    BOOL _dir;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign, getter = isDir) BOOL dir;

- (GAFilesEntry *)initWithPath:(NSString *)path name:(NSString *)name dir:(BOOL)dir;

@end
