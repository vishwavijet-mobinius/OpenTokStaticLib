//
//  OpenTokSession.h
//  OpenTokStaticLib
//
//  Created by vishwavijet on 10/7/16.
//  Copyright © 2016 mobinius.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>

typedef enum : int {
    OpenTokTopRightCorner,
    OpenTokTopLeftCorner,
    OpenTokBottomRightCorner,
    OpenTokBottomLeftCorner
} OpenTokPublisherViewPosition;

#pragma mark Session Protocol
@protocol OpenTokSessionDelegate <NSObject>

//Session delegate methods
-(void)openTokSesionConnectedWithSession:(OTSession *)session;

-(void)openTokSesionDidFailWithError:(OTError *)error;

//publisher delegate methods


//Subscriber delegate methods
-(void)subscriber:(OTSubscriberKit *)sub connectedToStream:(OTStream *)stream;

//Message delegate call
-(void)receivedMessageWithObject:(NSDictionary *)objectDict;

@end


#pragma mark Messaging Protocol
@protocol OpenTokSessionMessageDelegate <NSObject>

//Message delegate call
-(void)receivedMessageWithObject:(NSDictionary *)objectDict;

@end

#pragma mark Class OpenTokSession
@interface OpenTokSession : NSObject<OTSessionDelegate,OTPublisherKitDelegate,OTSubscriberKitDelegate>

@property(nonatomic, assign) id<OpenTokSessionDelegate> openTokDelegate;

@property(nonatomic, assign) id<OpenTokSessionMessageDelegate> openTokMessageDelegate;

@property (nonatomic,strong) OTSession *session;

@property (strong) NSMutableArray *allConnectionsIds;

@property (strong) NSMutableArray *allConnections;

@property (strong) NSMutableDictionary *messagesDict;

/*
 API to initialize the session.
 */
-(id)initWithAPIkey:(NSString *)apiKey withSession:(NSString *)session withToken:(NSString *)token withDelegate:(id<OpenTokSessionDelegate>)delegate;


/*
 Call this api to connect to the session and start the streaming.
 */
-(void)connect;


//API for two callers, Publisher & Subscriber
/*
 Load publisher view on top of subscriber view on any of the corners then use this API.
 If you use this API, then subcriber view will be the default larger view and u need to call
 the default API for subscriber which is "loadDefaultSubscriber"
 Also "onView" is the view on which u want to display the publisher and subscriber.
 */
-(void)startPublishingOnView:(UIView *)view atPosition:(OpenTokPublisherViewPosition)position;


/*
 Default subcriber view loader.
 */
-(void)loadDefaultSubscriberViewOnView:(UIView *)view;


/*
 Subcriber view loader for max 2 subsrcibers.
 */
-(void)loadSubscriber:(OTSubscriber *)sub withStream:(OTStream *)stream onView:(UIView *)view;


/*
 API to toggle camera from front & back.
 */
-(void)cameraToggle;


/*
 API to toggle audio to mute & unmute.
 */
-(void)audioToggle;


/*
 API to disconnect self from the session.
 */
-(void)disconnect;

/*
 API to send message to the connections in session.
 If connection is set to nil, everyone in the session will receive the message
 If connection is set, then only that particular connection will receive the message
 */
-(void)sendMessage:(NSString *)string connection:(OTConnection*)connection withType:(NSString *)type withDelegate:(id<OpenTokSessionMessageDelegate>)delegate;
@end
