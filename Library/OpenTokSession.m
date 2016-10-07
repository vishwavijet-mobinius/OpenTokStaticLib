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
@end

@implementation OpenTokSession

-(id)initWithAPIkey:(NSString *)apiKey withSession:(NSString *)session withToken:(NSString *)token withDelegate:(id<OpenTokSessionDelegate>)delegate{
    self.sessionId = session;
    self.token = token;
    self.session = [[OTSession alloc] initWithApiKey:apiKey sessionId:session delegate:self];
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
    [view addSubview:self.subscriber.view];
}


-(void)startSubscribingWithStream:(OTStream *)stream{
    self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    OTError *error;
    [self.session subscribe:self.subscriber error:&error];
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
        [self.openTokDelegate performSelector:@selector(openTokSesionDidFailWithError:) withObject:nil];
    }
}


-(void)session:(OTSession *)session streamCreated:(OTStream *)stream{
    if (self.subscriber == nil) {
        [self startSubscribingWithStream:stream];
    }
}


-(void)session:(OTSession *)session streamDestroyed:(OTStream *)stream{
    
}

#pragma mark Publisher Delegate Methods

-(void)publisher:(OTPublisherKit *)publisher didFailWithError:(OTError *)error{
    NSLog(@"***Publisher Failed publishing with error : %@",error.localizedDescription);
}

#pragma mark Subscriber Delegate methods

-(void)subscriber:(OTSubscriberKit *)subscriber didFailWithError:(OTError *)error{
    NSLog(@"***Subscriber Failed publishing with error : %@",error.localizedDescription);
}

-(void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber{
    NSLog(@"***Subscriber Connected***");
    if ([self.openTokDelegate respondsToSelector:@selector(subscriber:connectedToStream:)]){
        [self.openTokDelegate performSelector:@selector(subscriber:connectedToStream:) withObject:nil];
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
