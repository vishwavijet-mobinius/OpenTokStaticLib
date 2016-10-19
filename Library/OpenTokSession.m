//
//  OpenTokSession.m
//  OpenTokStaticLib
//
//  Created by vishwavijet on 10/7/16.
//  Copyright © 2016 mobinius.com. All rights reserved.
//

#import "OpenTokSession.h"

@interface OpenTokSession ()
@property(strong)NSString *token;
@property(strong)NSString *sessionId;

@property (strong) OTSession *session;
@property (strong) OTPublisher *publisher;
@property (strong) OTSubscriber *subscriber;

@property (strong) NSMutableDictionary *allStreams;
@property (strong) NSMutableDictionary *allSubscribers;
@property (strong) NSMutableArray *allConnectionsIds;

@property (strong) UIView *preview;

@end

@implementation OpenTokSession

-(id)initWithAPIkey:(NSString *)apiKey withSession:(NSString *)session withToken:(NSString *)token withDelegate:(id<OpenTokSessionDelegate>)delegate{
    self.sessionId = session;
    self.token = token;
    self.session = [[OTSession alloc] initWithApiKey:apiKey sessionId:session delegate:self];
    
    self.allConnectionsIds = [NSMutableArray new];
    self.allStreams = [NSMutableDictionary new];
    self.allSubscribers = [NSMutableDictionary new];
    return  self;
}

#pragma mark Class Methods
-(void)connect{
    OTError *error;
    [self.session connectWithToken:self.token error:&error];
    if (error) {
        NSLog(@"***Error on API Connect: %@",error.localizedDescription);
    }
}

-(void)disconnect{
    OTError *error;
    [self.session unpublish:self.publisher error:&error];
}

-(void)startPublishingOnView:(UIView *)view atPosition:(OpenTokPublisherViewPosition)position{
    self.publisher = [[OTPublisher alloc] initWithDelegate:self];
    OTError *error;
    [self.session publish:self.publisher error:&error];
    
    CGRect publisherRect;
    switch (position) {
        case OpenTokTopLeftCorner:
            publisherRect = CGRectMake(view.bounds.origin.x, view.bounds.origin.y, view.bounds.size.width/2, view.bounds.size.height/4);
            break;
        case OpenTokTopRightCorner:
            publisherRect = CGRectMake(view.bounds.size.width/2, view.bounds.origin.y, view.bounds.size.width/2, view.bounds.size.height/4);
            break;
        case OpenTokBottomLeftCorner:
            publisherRect = CGRectMake(view.bounds.origin.x, (view.bounds.size.height/4)*3, view.bounds.size.width/2, view.bounds.size.height/4);
            break;
        case OpenTokBottomRightCorner:
            publisherRect = CGRectMake(view.bounds.size.width/2, (view.bounds.size.height/4)*3, view.bounds.size.width/2, view.bounds.size.height/4);
            break;
    }
    self.publisher.view.frame = publisherRect;
    [view addSubview:self.publisher.view];
}


-(void)loadDefaultSubscriberViewOnView:(UIView *)view{
    self.subscriber.view.frame = CGRectMake(view.bounds.origin.x, view.bounds.origin.y, view.bounds.size.width, view.bounds.size.height);
    [view insertSubview:self.subscriber.view belowSubview:self.publisher.view];
}


-(void)loadSubscriber:(OTSubscriber *)sub withStream:(OTStream *)stream onView:(UIView *)view{
    self.preview = view;
    if (self.allConnectionsIds.count == 1){
        self.subscriber = sub ? sub : self.subscriber;
        self.subscriber.view.frame = CGRectMake(view.bounds.origin.x, view.bounds.origin.y, view.bounds.size.width, view.bounds.size.height);
        [view insertSubview:self.subscriber.view belowSubview:self.publisher.view];
    }
    else if (self.allConnectionsIds.count == 2){
        [self.subscriber.view removeFromSuperview];
        
        OTSubscriber *sub1 = [self.allSubscribers valueForKey:[self.allConnectionsIds objectAtIndex:0]];
        sub1.view.frame = CGRectMake(view.bounds.origin.x, view.bounds.origin.y, view.bounds.size.width, view.bounds.size.height/2);
        [view insertSubview:sub1.view belowSubview:self.publisher.view];
        
        OTSubscriber *sub2 = [self.allSubscribers valueForKey:[self.allConnectionsIds objectAtIndex:1]];
        sub2.view.frame = CGRectMake(view.bounds.origin.x, view.bounds.size.height/2, view.bounds.size.width, view.bounds.size.height/2);
        [view insertSubview:sub2.view belowSubview:self.publisher.view];
    }
}


-(void)startSubscribingWithStream:(OTStream *)stream{
    OTSubscriber *sub = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    OTError *error;
    [self.session subscribe:sub error:&error];
    if (error) {
        NSLog(@"***Failed to subscribe Subscriber : %@",error.localizedDescription);
    }
}

#pragma mark OTSession Delegate Methods
-(void)sessionDidConnect:(OTSession *)session{
    NSLog(@"***Session Connected for ID : %@",session.sessionId);
    if ([self.openTokDelegate respondsToSelector:@selector(openTokSesionConnectedWithSession:)]){
        [self.openTokDelegate performSelector:@selector(openTokSesionConnectedWithSession:) withObject:nil];
    }
}


-(void)sessionDidDisconnect:(OTSession *)session{
    
}


-(void)session:(OTSession *)session didFailWithError:(OTError *)error{
    NSLog(@"***Session Connection failed with error : %@",error.localizedDescription);
    if ([self.openTokDelegate respondsToSelector:@selector(openTokSesionDidFailWithError:)]){
        [self.openTokDelegate performSelector:@selector(openTokSesionDidFailWithError:) withObject:error];
    }
}


-(void)session:(OTSession *)session streamCreated:(OTStream *)stream{
    [self startSubscribingWithStream:stream];
}


-(void)session:(OTSession *)session streamDestroyed:(OTStream *)stream{
    
}


-(void)session:(OTSession*) session connectionCreated:(OTConnection*) connection{
    
}


-(void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection{
 
    if ([self.allConnectionsIds containsObject:connection.connectionId] && self.preview != nil) {
        [self.allConnectionsIds removeObject:connection.connectionId];
        [self.allSubscribers removeObjectForKey:connection.connectionId];
        [self.allStreams removeObjectForKey:connection.connectionId];
        
        self.subscriber = [self.allSubscribers objectForKey:self.allConnectionsIds.firstObject];
        [self loadSubscriber:nil withStream:nil onView:self.preview];
    }
}

#pragma mark Publisher Delegate Methods

-(void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error{
    NSLog(@"***Publisher Failed publishing with error : %@",error.localizedDescription);
}

- (void)publisher:(OTPublisherKit*)publisher streamDestroyed:(OTStream*)stream{
    NSLog(@"***Publisher Stopped Streaming & disconnecting from session");
    self.publisher = nil;
    _allConnectionsIds = nil;
    _allStreams= nil;
    _allSubscribers = nil;
}

#pragma mark Subscriber Delegate methods

-(void)subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error{
    NSLog(@"***Subscriber Failed publishing with error : %@",error.localizedDescription);
}

-(void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber{
    NSLog(@"***Subscriber Connected***");
    
    // create subscriber
    OTSubscriber *sub = (OTSubscriber *)subscriber;
    [self.allSubscribers setObject:subscriber forKey:sub.stream.connection.connectionId];
    [self.allConnectionsIds addObject:sub.stream.connection.connectionId];
    [self.allStreams setObject:sub.stream forKey:sub.stream.connection.connectionId];
    
    self.subscriber = self.allConnectionsIds.count == 1 ? sub : nil;
    if ([self.openTokDelegate respondsToSelector:@selector(subscriber:connectedToStream:)]){
        [self.openTokDelegate performSelector:@selector(subscriber:connectedToStream:) withObject:subscriber.stream];
    }
}

#pragma mark Camera and Audio methods

-(void)cameraToggle{
    self.publisher.cameraPosition = self.publisher.cameraPosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
}

-(void)audioToggle{
    self.publisher.publishAudio = self.publisher.publishAudio == true ? false : true;
}

@end
