//
//  SonosDiscovery.h
//  SonosKit
//
//  Created by Nathan Borror on 3/16/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncUdpSocket.h>

@interface SonosDiscovery : NSObject <GCDAsyncUdpSocketDelegate>

+ (void)discoverControllers:(void(^)(NSArray *controllers, NSError *error))completion;

@end
