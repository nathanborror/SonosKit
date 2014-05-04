//
//  SonosControllerStore.m
//  SonosKit
//
//  Created by Nathan Borror on 3/16/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "SonosControllerStore.h"
#import "SonosController.h"
#import "SonosDiscovery.h"

@implementation SonosControllerStore

+ (SonosControllerStore *)sharedStore
{
  static SonosControllerStore *sharedStore = nil;
  if (!sharedStore) {
    sharedStore = [[SonosControllerStore alloc] init];
  }
  return sharedStore;
}

- (instancetype)init
{
  if (self = [super init]) {
    NSString *path = [self archivePath];
    _allControllers = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

    if (!_allControllers) {
      // Find available controllers on the network
      [self discoverControllers];
    } else {
      // Use archived controllers and re-organize them so we know which are
      // slaves and which are coordinators.
      [self refreshControllers];
    }
  }
  return self;
}

- (SonosController *)getControllerByUUID:(NSString *)uuid
{
  for (SonosController *controller in _allControllers) {
    if ([controller.uuid isEqualToString:uuid]) {
      return controller;
    }
  }
  return nil;
}

- (NSArray *)data
{
  NSMutableArray *data = [NSMutableArray array];
  for (SonosController *coordinator in _coordinators) {
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:coordinator.slaves];
    [controllers addObject:coordinator];
    [data addObject:controllers];
  }
  return [NSArray arrayWithArray:data];
}

- (void)discoverControllers
{
  [SonosDiscovery discoverControllers:^(NSArray *objects, NSError *error) {
    [self willChangeValueForKey:@"allControllers"];

    NSMutableArray *controllers = [[NSMutableArray alloc] init];

    for (NSDictionary *obj in objects) {
      SonosController *controller = [[SonosController alloc] initWithIP:obj[@"ip"]];
      [controller setName:obj[@"name"]];
      [controller setGroup:obj[@"group"]];
      [controller setUuid:obj[@"uuid"]];
      [controller setCoordinator:[obj[@"coordinator"] boolValue]];
      [controllers addObject:controller];
    }

    _allControllers = [NSArray arrayWithArray:controllers];
    [self organizeControllers];

    [self didChangeValueForKey:@"allControllers"];
  }];
}

- (void)refreshControllers
{
  // Refresh the current state of all the controllers
  [self organizeControllers];
}

- (void)organizeControllers
{
  [self willChangeValueForKey:@"data"];
  NSMutableArray *coordinators = [[NSMutableArray alloc] init];
  NSMutableArray *slaves = [[NSMutableArray alloc] init];

  // Break out coordinators and slaves into arrays
  for (SonosController *controller in _allControllers) {
    // Set slaves to nil since we're about to reassign all of them
    [controller removeAllSlaves];

    if (controller.isCoordinator) {
      [coordinators addObject:controller];
    } else {
      [slaves addObject:controller];
    }
  }

  // Assign slaves to their respective coordinators
  for (SonosController *slave in slaves) {
    for (SonosController *coordinator in coordinators) {
      if ([coordinator.group isEqualToString:slave.group]) {
        [coordinator addSlave:slave];
        break;
      }
    }
  }

  _slaves = [NSArray arrayWithArray:slaves];
  _coordinators = [NSArray arrayWithArray:coordinators];
  [self didChangeValueForKey:@"data"];
}

- (void)pairController:(SonosController *)controller1 with:(SonosController *)controller2
{
  [controller1 changeCoordinatorTo:controller2 completion:nil];
  [controller1 setGroup:controller2.group];
  [controller1 setCoordinator:NO];

  [controller2 setCoordinator:YES];

  [self organizeControllers];
}

#pragma mark - NSCoding

- (NSString *)archivePath
{
  NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [documentDirectories objectAtIndex:0];
  return [documentDirectory stringByAppendingPathComponent:@"sonos.controller.archive"];
}

- (BOOL)saveChanges
{
  NSString *path = [self archivePath];
  return [NSKeyedArchiver archiveRootObject:_allControllers toFile:path];
}

@end