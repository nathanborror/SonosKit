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

@interface SonosController : NSObject <NSCoding>

@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, readonly) NSArray *slaves;
@property (nonatomic, assign, getter = isCoordinator) BOOL coordinator;

- (instancetype)initWithIP:(NSString *)ip;

- (void)getDescription:(void(^)(NSDictionary *response, NSError *error))block;

// AVTransport

- (void)queue:(NSString *)track completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)getMediaInfo:(void(^)(NSDictionary *response, NSError *error))block;
- (void)getTransportInfo:(void(^)(BOOL playing, NSDictionary *response, NSError *error))block;
- (void)getPositionInfo:(void(^)(NSDictionary *track, NSDictionary *response, NSError *error))block;
- (void)getDeviceCapabilities:(void(^)(NSDictionary *response, NSError *error))block;
- (void)getTransportSettings:(void(^)(NSDictionary *response, NSError *error))block;
- (void)stop:(void(^)(NSDictionary *response, NSError *error))block;
- (void)play:(NSString *)uri completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)pause:(void(^)(NSDictionary *response, NSError *error))block;
- (void)next:(void(^)(NSDictionary *response, NSError *error))block;
- (void)previous:(void(^)(NSDictionary *response, NSError *error))block;
//- (void)becomeCoordinatorOfStandaloneGroup:(void(^)(NSDictionary *response, NSError *error))block;
//- (void)delegateGroupCoordinationTo:(NSString *)memberId completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)changeCoordinatorTo:(SonosController *)coordinator completion:(void(^)(NSDictionary *response, NSError *error))block;

// ConnectionManager

- (void)getProtocolInfo:(void(^)(NSDictionary *response, NSError *error))block;
- (void)getCurrentConnectionIDs:(void(^)(NSDictionary *response, NSError *error))block;
- (void)getCurrentConnectionInfo:(void(^)(NSDictionary *response, NSError *error))block;

// RenderingControl

- (void)getMute:(void(^)(NSDictionary *response, NSError *error))block;
- (void)setMute:(void(^)(NSDictionary *response, NSError *error))block;
- (void)getVolume:(void(^)(NSInteger volume, NSDictionary *response, NSError *error))block;
- (void)setVolume:(NSInteger)volume completion:(void(^)(NSDictionary *response, NSError *error))block;
- (void)lineIn:(void(^)(NSDictionary *response, NSError *error))block;

// ContentDirectory

- (void)browseContent:(void(^)(NSDictionary *response, NSError *error))block;

// Queue

- (void)browseQueue:(void(^)(NSDictionary *response, NSError *error))block;

// AlarmClock

- (void)listAlarms:(void(^)(NSDictionary *alarms, NSDictionary *response, NSError *error))block;

// MusicServices

- (void)listAvailableServices:(void(^)(NSDictionary *services, NSDictionary *response, NSError *error))block;

// DeviceProperties

- (void)getZoneAttributes:(void(^)(NSDictionary *response, NSError *error))block;
- (void)getZoneInfo:(void(^)(NSDictionary *response, NSError *error))block;

// ZoneGroupTopology

- (void)getZoneGroupAttributes:(void(^)(NSDictionary *response, NSError *error))block;
- (void)getZoneGroupState:(void(^)(NSDictionary *response, NSError *error))block;

// Helpers

- (void)addSlave:(SonosController *)slave;
- (void)removeSlave:(SonosController *)slave;
- (void)removeAllSlaves;

@end