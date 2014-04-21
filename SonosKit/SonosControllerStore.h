//
//  SonosControllerStore.h
//  SonosKit
//
//  Created by Nathan Borror on 3/16/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SonosController;

@interface SonosControllerStore : NSObject

@property (nonatomic, readonly) NSArray *allControllers;
@property (nonatomic, readonly) NSArray *coordinators;
@property (nonatomic, readonly) NSArray *slaves;
@property (nonatomic, readonly) NSArray *data;

+ (SonosControllerStore *)sharedStore;
- (SonosController *)getControllerByUUID:(NSString *)uuid;
- (BOOL)saveChanges;
- (void)pairController:(SonosController *)controller1 with:(SonosController *)controller2;

@end
