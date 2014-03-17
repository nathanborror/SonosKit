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

@implementation SonosControllerStore {
  NSMutableArray *_slaves;
  NSMutableArray *_coordinators;
}

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
    _coordinators = [[NSMutableArray alloc] init];
    _slaves = [[NSMutableArray alloc] init];

    [SonosDiscovery discoverControllers:^(NSArray *objects, NSError *error) {
      [self willChangeValueForKey:@"allControllers"];

      for (NSDictionary *obj in objects) {
        SonosController *controller = [[SonosController alloc] initWithIP:obj[@"ip"]];
        [controller setName:obj[@"name"]];
        [controller setGroup:obj[@"group"]];
        [controller setUuid:obj[@"uuid"]];
        [controller setCoordinator:[obj[@"coordinator"] boolValue]];

        if ([controller isCoordinator]) {
          [_coordinators addObject:controller];
        } else {
          [_slaves addObject:controller];
        }
      }

      for (SonosController *slave in _slaves) {
        for (SonosController *coordinator in _coordinators) {
          if ([coordinator.group isEqualToString:slave.group]) {
            [coordinator addSlave:slave];
            break;
          }
        }
      }

      if ([self allControllers].count > 0) {
        [self willChangeValueForKey:@"currentController"];
        _currentController = [_coordinators objectAtIndex:0];
        for (SonosController *controller in _coordinators) {
          [controller playbackStatus:^(BOOL playing, NSDictionary *response, NSError *error) {
            if (playing) _currentController = controller;
          }];
        }
        [self didChangeValueForKey:@"currentController"];
      }

      [self didChangeValueForKey:@"allControllers"];
    }];
  }
  return self;
}

- (NSArray *)allControllers
{
  return [_coordinators arrayByAddingObjectsFromArray:_slaves];
}

- (NSArray *)slaves
{
  return [_slaves copy];
}

- (NSArray *)coordinators
{
  return [_coordinators copy];
}

@end
