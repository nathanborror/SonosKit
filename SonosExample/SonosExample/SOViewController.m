//
//  SOViewController.m
//  SonosExample
//
//  Created by Nathan Borror on 3/17/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "SOViewController.h"
#import "SonosControllerStore.h"

@implementation SOViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self.view setBackgroundColor:[UIColor whiteColor]];

  [[SonosControllerStore sharedStore] addObserver:self forKeyPath:@"allControllers" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  NSLog(@"%@", [[SonosControllerStore sharedStore] allControllers]);
}

@end
