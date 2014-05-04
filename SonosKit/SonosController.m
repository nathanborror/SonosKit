//
//  SonosController.m
//  SonosKit
//
//  Created by Nathan Borror on 12/31/12.
//  Copyright (c) 2012 Nathan Borror. All rights reserved.
//

#import "SonosController.h"
#import "XMLReader.h"

@implementation SonosController {
  NSInteger _volumeLevel;
  NSMutableArray *_slaves;
}

- (instancetype)initWithIP:(NSString *)ip
{
  if (self = [super init]) {
    _volumeLevel = 0;
    _ip = ip;
    _slaves = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)request:(SonosRequestType)type action:(NSString *)action params:(NSDictionary *)params completion:(void (^)(id, NSError *))block
{
  NSURL *url;
  NSString *ns;

  switch (type) {
    case SonosRequestTypeAVTransport:
      // http://SPEAKER_IP:1400/xml/AVTransport1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaRenderer/AVTransport/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:AVTransport:1";
      break;
    case SonosRequestTypeConnectionManager:
      // http://SPEAKER_IP:1400/xml/ConnectionManager1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaServer/ConnectionManager/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:ConnectionManager:1";
      break;
    case SonosRequestTypeRenderingControl:
      // http://SPEAKER_IP:1400/xml/RenderingControl1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaRenderer/RenderingControl/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:RenderingControl:1";
      break;
    case SonosRequestTypeContentDirectory:
      // http://SPEAKER_IP:1400/xml/ContentDirectory1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaServer/ContentDirectory/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:ContentDirectory:1";
      break;
    case SonosRequestTypeQueue:
      // http://SPEAKER_IP:1400/xml/Queue1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MediaRenderer/Queue/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:Queue:1";
      break;
    case SonosRequestTypeAlarmClock:
      // http://SPEAKER_IP:1400/xml/AlarmClock1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/AlarmClock/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:AlarmClock:1";
      break;
    case SonosRequestTypeMusicServices:
      // http://SPEAKER_IP:1400/xml/MusicServices1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/MusicServices/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:MusicServices:1";
      break;
    case SonosRequestTypeAudioIn:
      // http://SPEAKER_IP:1400/xml/AudioIn1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/AudioIn/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:AudioIn:1";
      break;
    case SonosRequestTypeDeviceProperties:
      // http://SPEAKER_IP:1400/xml/DeviceProperties1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/DeviceProperties/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:DeviceProperties:1";
      break;
    case SonosRequestTypeSystemProperties:
      // http://SPEAKER_IP:1400/xml/SystemProperties1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/SystemProperties/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:SystemProperties:1";
      break;
    case SonosRequestTypeZoneGroupTopology:
      // http://SPEAKER_IP:1400/xml/ZoneGroupTopology1.xml
      url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/ZoneGroupTopology/Control", _ip]];
      ns = @"urn:schemas-upnp-org:service:ZoneGroupTopology:1";
      break;
    case SonosRequestTypeGroupManagement:
      break;
  }

  NSMutableString *requestParams = [[NSMutableString alloc] init];
  NSEnumerator *enumerator = [params keyEnumerator];
  NSString *key;
  while (key = [enumerator nextObject]) {
    requestParams = [NSMutableString stringWithFormat:@"<%@>%@</%@>%@", key, [params objectForKey:key], key, requestParams];
  }

  NSString *requestBody = [NSString stringWithFormat:@""
    "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/' s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
      "<s:Body>"
        "<u:%@ xmlns:u='%@'>%@</u:%@>"
      "</s:Body>"
    "</s:Envelope>", action, ns, requestParams, action];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
  [request addValue:[NSString stringWithFormat:@"%@#%@", ns, action] forHTTPHeaderField:@"SOAPACTION"];
  [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];

  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 200) return;

    NSDictionary *responseDict = [XMLReader dictionaryForXMLData:data options:XMLReaderOptionsProcessNamespaces error:&error];
    NSDictionary *body = responseDict[@"Envelope"][@"Body"];

    dispatch_async(dispatch_get_main_queue(), ^{
      if (block) block(body, nil);
    });
  }];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [task resume];
  });
}

- (void)getDescription:(void (^)(NSDictionary *, NSError *))block
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:1400/xml/device_description.xml", _ip]];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];

  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 200) return;

    NSDictionary *responseDict = [XMLReader dictionaryForXMLData:data options:XMLReaderOptionsProcessNamespaces error:&error];

    dispatch_async(dispatch_get_main_queue(), ^{
      if (block) block(responseDict, nil);
    });
  }];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [task resume];
  });
}

#pragma mark - AVTransport

- (void)queue:(NSString *)track completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0,
                           @"EnqueuedURI": track,
                           @"EnqueuedURIMetaData": @"",
                           @"DesiredFirstTrackNumberEnqueued": @0,
                           @"EnqueueAsNext": @1};
  [self request:SonosRequestTypeAVTransport action:@"AddURIToQueue" params:params completion:^(id obj, NSError *error) {
    [self play:nil completion:block];
  }];
}

- (void)getMediaInfo:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0};
  [self request:SonosRequestTypeAVTransport action:@"GetMediaInfo" params:params completion:block];
}

- (void)getTransportInfo:(void (^)(BOOL, NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0};
  [self request:SonosRequestTypeAVTransport action:@"GetTransportInfo" params:params completion:^(NSDictionary *response, NSError *error) {
    if (error) {
      block(NO, nil, error);
      return;
    }

    if ([response[@"CurrentTransportState"] isEqualToString:@"PLAYING"]) {
      block(YES, response, nil);
      return;
    }

    block(NO, response, nil);
  }];
}

- (void)getPositionInfo:(void (^)(NSDictionary *, NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0};
  [self request:SonosRequestTypeAVTransport action:@"GetPositionInfo" params:params completion:^(NSDictionary *response, NSError *error) {
    if (!error) {
      NSString *trackData = response[@"GetPositionInfoResponse"][@"TrackMetaData"][@"text"];
      NSDictionary *track = [XMLReader dictionaryForXMLString:trackData options:XMLReaderOptionsProcessNamespaces error:&error];
      block(track[@"DIDL-Lite"][@"item"], response, error);
      return;
    }

    block(nil, response, error);
  }];
}

- (void)getDeviceCapabilities:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0};
  [self request:SonosRequestTypeAVTransport action:@"GetDeviceCapabilities" params:params completion:block];
}

- (void)getTransportSettings:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0};
  [self request:SonosRequestTypeAVTransport action:@"GetTransportSettings" params:params completion:block];
}

- (void)stop:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Speed": @1};
  [self request:SonosRequestTypeAVTransport action:@"Stop" params:params completion:^(id obj, NSError *error) {
    if (block) block(obj, error);
  }];
}

- (void)play:(NSString *)uri completion:(void (^)(NSDictionary *, NSError *))block
{
  if (uri) {
    NSDictionary *params = @{@"InstanceID": @0, @"CurrentURI":uri, @"CurrentURIMetaData": @""};
    [self request:SonosRequestTypeAVTransport action:@"SetAVTransportURI" params:params completion:^(id obj, NSError *error) {
      [self play:nil completion:block];
    }];
  } else {
    NSDictionary *params = @{@"InstanceID": @0, @"Speed":@1};
    [self request:SonosRequestTypeAVTransport action:@"Play" params:params completion:^(id obj, NSError *error) {
      if (block) block(obj, error);
    }];
  }
}

- (void)pause:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Speed": @1};
  [self request:SonosRequestTypeAVTransport action:@"Pause" params:params completion:^(id obj, NSError *error) {
    if (block) block(obj, error);
  }];
}

- (void)next:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Speed": @1};
  [self request:SonosRequestTypeAVTransport action:@"Next" params:params completion:^(id obj, NSError *error) {
    if (block) block(obj, error);
  }];
}

- (void)previous:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Speed": @1};
  [self request:SonosRequestTypeAVTransport action:@"Previous" params:params completion:^(id obj, NSError *error) {
    if (block) block(obj, error);
  }];
}

- (void)changeCoordinatorTo:(SonosController *)coordinator completion:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0,
                           @"CurrentURI": [NSString stringWithFormat:@"x-rincon:%@", coordinator.uuid],
                           @"CurrentURIMetaData": @""};
  [self request:SonosRequestTypeAVTransport action:@"SetAVTransportURI" params:params completion:block];
}

#pragma mark - ConnectionManager

- (void)getProtocolInfo:(void(^)(NSDictionary *, NSError *))block
{
  [self request:SonosRequestTypeConnectionManager action:@"GetProtocolInfo" params:nil completion:block];
}

- (void)getCurrentConnectionIDs:(void(^)(NSDictionary *, NSError *))block
{
  [self request:SonosRequestTypeConnectionManager action:@"GetCurrentConnectionIDs" params:nil completion:block];
}

- (void)getCurrentConnectionInfo:(void(^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"CurrentConnectionIDs": @0};
  [self request:SonosRequestTypeConnectionManager action:@"GetCurrentConnectionInfo" params:params completion:block];
}

#pragma mark - RenderingControl

- (void)getMute:(void(^)(NSDictionary *response, NSError *error))block
{
  NSDictionary *params = @{@"InstanceID": @0};
  [self request:SonosRequestTypeRenderingControl action:@"GetMute" params:params completion:block];
}

- (void)setMute:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Channel":@"Master", @"DesiredMute": @1};
  [self request:SonosRequestTypeRenderingControl action:@"SetMute" params:params completion:block];
}

- (void)getVolume:(void (^)(NSInteger, NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"InstanceID": @0, @"Channel":@"Master"};
  [self request:SonosRequestTypeRenderingControl action:@"GetVolume" params:params completion:^(NSDictionary *response, NSError *error) {
    if (!error) {
      NSInteger volume = [response[@"GetVolumeResponse"][@"CurrentVolume"][@"text"] integerValue];
      block(volume, response, error);
      return;
    }
    block(0, response, error);
  }];
}

- (void)setVolume:(NSInteger)volume completion:(void (^)(NSDictionary *, NSError *))block
{
  // This helps throttle requests so we're not flodding the speaker.
  if (_volumeLevel == volume) return;

  NSDictionary *params = @{@"InstanceID": @0, @"Channel":@"Master", @"DesiredVolume":[NSNumber numberWithInt:volume]};
  [self request:SonosRequestTypeRenderingControl action:@"SetVolume" params:params completion:^(NSDictionary *response, NSError *error) {
    _volumeLevel = volume;
    if (block) block(response, error);
  }];
}

- (void)lineIn:(void (^)(NSDictionary *, NSError *))block
{
  [self play:[NSString stringWithFormat:@"x-rincon-stream:%@", _uuid] completion:block];
}

#pragma mark - ContentDirectory

- (void)browseContent:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"ObjectID": @"A:ARTIST",
                           @"BrowseFlag": @"BrowseDirectChildren",
                           @"Filter": @"*",
                           @"StartingIndex": @0,
                           @"RequestedCount": @5,
                           @"SortCriteria": @"*"};
  [self request:SonosRequestTypeContentDirectory action:@"Browse" params:params completion:block];
}

#pragma mark - Queue

- (void)browseQueue:(void (^)(NSDictionary *, NSError *))block
{
  NSDictionary *params = @{@"QueueID": @0, @"StartingIndex": @0, @"RequestedCount": @0};
  [self request:SonosRequestTypeQueue action:@"Browse" params:params completion:block];
}

#pragma mark - AlarmClock

- (void)listAlarms:(void (^)(NSDictionary *, NSDictionary *, NSError *))block
{
  [self request:SonosRequestTypeAlarmClock action:@"ListAlarms" params:nil completion:^(NSDictionary *response, NSError *error) {
    NSDictionary *alarms = [XMLReader dictionaryForXMLString:response[@"ListAlarmsResponse"][@"CurrentAlarmList"][@"text"] options:XMLReaderOptionsProcessNamespaces error:&error];
    if (block) block(alarms, response, error);
  }];
}

#pragma mark - MusicServices

- (void)listAvailableServices:(void (^)(NSDictionary *, NSDictionary *, NSError *))block
{
  [self request:SonosRequestTypeMusicServices action:@"ListAvailableServices" params:nil completion:^(NSDictionary *response, NSError *error) {
    NSDictionary *services = [XMLReader dictionaryForXMLString:response[@"ListAvailableServicesResponse"][@"AvailableServiceDescriptorList"][@"text"] options:XMLReaderOptionsProcessNamespaces error:&error];
    if (block) block(services, response, error);
  }];
}

#pragma mark - DeviceProperties

- (void)getZoneAttributes:(void(^)(NSDictionary *, NSError *))block
{
  [self request:SonosRequestTypeDeviceProperties action:@"GetZoneAttributes" params:nil completion:block];
}

- (void)getZoneInfo:(void(^)(NSDictionary *, NSError *))block
{
  [self request:SonosRequestTypeDeviceProperties action:@"GetZoneInfo" params:nil completion:block];
}

#pragma mark - ZoneGroupTopology

- (void)getZoneGroupAttributes:(void(^)(NSDictionary *, NSError *))block
{
  [self request:SonosRequestTypeZoneGroupTopology action:@"GetZoneGroupAttributes" params:nil completion:block];
}

- (void)getZoneGroupState:(void(^)(NSDictionary *, NSError *))block
{
  [self request:SonosRequestTypeZoneGroupTopology action:@"GetZoneGroupState" params:nil completion:^(NSDictionary *response, NSError *error) {
    NSDictionary *responseDict = [XMLReader dictionaryForXMLString:response[@"GetZoneGroupStateResponse"][@"ZoneGroupState"][@"text"] options:XMLReaderOptionsProcessNamespaces error:&error];
    if (block) block(responseDict, error);
  }];
}

# pragma mark - Helpers

- (NSArray *)slaves
{
  return (NSArray *)[_slaves copy];
}

- (void)addSlave:(SonosController *)slave
{
  [_slaves addObject:slave];
}

- (void)removeSlave:(SonosController *)slave
{
  [_slaves removeObjectIdenticalTo:slave];
}

- (void)removeAllSlaves
{
  [_slaves removeAllObjects];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self) {
    [self setIp:[aDecoder decodeObjectForKey:@"ip"]];
    [self setGroup:[aDecoder decodeObjectForKey:@"group"]];
    [self setName:[aDecoder decodeObjectForKey:@"name"]];
    [self setUuid:[aDecoder decodeObjectForKey:@"uuid"]];
    [self setCoordinator:[aDecoder decodeBoolForKey:@"coordinator"]];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_ip forKey:@"ip"];
  [aCoder encodeObject:_group forKey:@"group"];
  [aCoder encodeObject:_name forKey:@"name"];
  [aCoder encodeObject:_uuid forKey:@"uuid"];
  [aCoder encodeBool:_coordinator forKey:@"coordinator"];
}

@end