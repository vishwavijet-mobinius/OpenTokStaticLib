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

@property (strong) OTPublisher *publisher;
@property (strong) OTSubscriber *subscriber;
@property (strong) NSMutableDictionary *allSubscribers;
@property (strong) NSMutableDictionary *allStreams;


@property (strong) UIView *preview;

@end

@implementation OpenTokSession
@synthesize allConnectionsIds,allSubscribers,allConnections,messagesDict;

-(id)initWithAPIkey:(NSString *)apiKey withSession:(NSString *)session withToken:(NSString *)token withDelegate:(id<OpenTokSessionDelegate>)delegate{
    self.sessionId = session;
    self.token = token;
    self.session = [[OTSession alloc] initWithApiKey:apiKey sessionId:session delegate:self];
    
    self.allConnectionsIds = [NSMutableArray new];
    self.allConnections = [NSMutableArray new];
    self.allStreams = [NSMutableDictionary new];
    self.allSubscribers = [NSMutableDictionary new];
    
    self.messagesDict = [NSMutableDictionary new];
    self.messagesDict[@"group"] = [NSMutableArray new];
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
            publisherRect = CGRectMake(view.bounds.origin.x+20, view.bounds.origin.y+20, view.bounds.size.width/3, view.bounds.size.height/4);
            break;
        case OpenTokTopRightCorner:
            publisherRect = CGRectMake(view.bounds.size.width/2+20, view.bounds.origin.y+20, view.bounds.size.width/3, view.bounds.size.height/4);
            break;
        case OpenTokBottomLeftCorner:
            publisherRect = CGRectMake(view.bounds.origin.x+20, (view.bounds.size.height/4)*3, view.bounds.size.width/3, view.bounds.size.height/4);
            break;
        case OpenTokBottomRightCorner:
            publisherRect = CGRectMake(view.bounds.size.width/2+20, (view.bounds.size.height/4)*3, view.bounds.size.width/3, view.bounds.size.height/4);
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

-(void)sendMessage:(NSString *)string connection:(OTConnection*)connection withType:(NSString *)type withDelegate:(id<OpenTokSessionMessageDelegate>)delegate{
    OTError *error;
    [self.session signalWithType:type string:string connection:connection error:&error];
    if (error) {
        NSLog(@"Message sending failed with error : %@",error.localizedDescription);
    }
    if (connection != nil){
        [self.messagesDict[connection.connectionId] addObject:@{@"msg":string,@"time":self.todayDate,@"fromSelf":@YES}];
    }
}

-(NSString *)todayDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yy h:mm a";
    return [dateFormatter stringFromDate:NSDate.date];
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
    OTConnection *connection = stream.connection;
    if ([self.allConnectionsIds containsObject:connection.connectionId] && self.preview != nil) {
        
        OTSubscriber *sub = [self.allSubscribers objectForKey:connection.connectionId];
        [sub.view removeFromSuperview];
        [self.allConnectionsIds removeObject:connection.connectionId];
        [self.allConnections removeObject:connection];
        [self.allSubscribers removeObjectForKey:connection.connectionId];
        [self.allStreams removeObjectForKey:connection.connectionId];
        self.subscriber = [self.allSubscribers objectForKey:self.allConnectionsIds.firstObject];
        [self loadSubscriber:nil withStream:nil onView:self.preview];
    }
}


-(void)session:(OTSession*) session connectionCreated:(OTConnection*) connection{
    
}


-(void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection{
 
    if ([self.allConnectionsIds containsObject:connection.connectionId] && self.preview != nil) {
        [self.allConnectionsIds removeObject:connection.connectionId];
        [self.allConnections removeObject:connection];
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
    allConnectionsIds = nil;
    allConnections = nil;
    _allStreams= nil;
    allSubscribers = nil;
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
    [self.allConnections addObject:sub.stream.connection];
    [self.allStreams setObject:sub.stream forKey:sub.stream.connection.connectionId];
    self.messagesDict[sub.stream.connection.connectionId] = [NSMutableArray new];
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


#pragma mark Message delegate methods

- (void)   session:(OTSession*)session
receivedSignalType:(NSString*)type
    fromConnection:(OTConnection*)connection
        withString:(NSString*)string
{
    NSDictionary *object;
    
    if ([type isEqualToString:@"group"]){
        if ([self.session.connection.connectionId isEqualToString:connection.connectionId]){
            object = @{@"session":session,@"type":type,@"connection":connection,@"message":@{@"msg":string,@"time":self.todayDate,@"fromSelf":@YES}};
        }
        else{
            object = @{@"session":session,@"type":type,@"connection":connection,@"message":@{@"msg":string,@"time":self.todayDate,@"fromSelf":@NO}};
        }
        [self.messagesDict[@"group"] addObject:object[@"message"]];
    }
    else{
        object = @{@"session":session,@"type":type,@"connection":connection,@"message":@{@"msg":string,@"time":self.todayDate,@"fromSelf":@NO}};
        [self.messagesDict[connection.connectionId] addObject:object[@"message"]];
    }
    
    if (self.openTokMessageDelegate != nil){
        if ([self.openTokMessageDelegate respondsToSelector:@selector(receivedMessageWithObject:)]){
            [self.openTokMessageDelegate performSelector:@selector(receivedMessageWithObject:) withObject:object];
        }
    }
    else{
        if ([self.openTokDelegate respondsToSelector:@selector(receivedMessageWithObject:)]){
            [self.openTokDelegate performSelector:@selector(receivedMessageWithObject:) withObject:object];
        }
    }
    
}
@end
