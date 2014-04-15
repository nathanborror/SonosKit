//
//  SonosController.h
//  SonosKit
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SonosRequestType) {
  SonosRequestTypeAVTransport,
  SonosRequestTypeConnectionManager,
  SonosRequestTypeRenderingControl,
  SonosRequestTypeContentDirectory,
  SonosRequestTypeQueue,
  SonosRequestTypeAlarmClock,
  SonosRequestTypeMusicServices,
  SonosRequestTypeAudioIn,
  SonosRequestTypeDeviceProperties,
  SonosRequestTypeSystemProperties,
  SonosRequestTypeZoneGroupTopology,
  SonosRequestTypeGroupManagement,
};

@interface SonosController : NSObject

@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, readonly) NSArray *slaves;
@property (nonatomic, assign, getter = isCoordinator) BOOL coordinator;

- (instancetype)initWithIP:(NSString *)ip;

- (void)play:(NSString *)uri completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)playbackStatus:(void(^)(BOOL playing, NSDictionary *response, NSError *error))block;
- (void)pause:(void(^)(NSDictionary *response, NSError *error))block;
- (void)stop:(void(^)(NSDictionary *response, NSError *error))block;
- (void)next:(void(^)(NSDictionary *response, NSError *error))block;
- (void)previous:(void(^)(NSDictionary *response, NSError *error))block;
- (void)queue:(NSString *)track completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)getVolume:(void(^)(NSInteger volume, NSDictionary *response, NSError *error))block;
- (void)setVolume:(NSInteger)volume completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)lineIn:(void(^)(NSDictionary *response, NSError *error))block;
- (void)trackInfo:(void(^)(NSDictionary *track, NSDictionary *response, NSError *error))block;
- (void)mediaInfo:(void(^)(NSDictionary *response, NSError *error))block;
- (void)status:(void(^)(NSDictionary *response, NSError *error))block;
- (void)browse:(void(^)(NSDictionary *response, NSError *error))block;

- (void)addSlave:(SonosController *)slave;

@end