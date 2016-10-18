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

@protocol OpenTokSessionDelegate <NSObject>

//Session delegate methods
-(void)openTokSesionConnectedWithSession:(OTSession *)session;

-(void)openTokSesionDidFailWithError:(OTError *)session;

//publisher delegate methods


//Subscriber delegate methods
-(void)subscriber:(OTSubscriberKit *)sub connectedToStream:(OTStream *)stream;

@end


@interface OpenTokSession : NSObject<OTSessionDelegate,OTPublisherKitDelegate,OTSubscriberKitDelegate>

@property(nonatomic, assign) id<OpenTokSessionDelegate> openTokDelegate;

/*
 API to initialize the session.
 */
-(id)initWithAPIkey:(NSString *)apiKey withSession:(NSString *)session withToken:(NSString *)token withDelegate:(id<OpenTokSessionDelegate>)delegate;


/*
 Call this api to connect to the session and start the streaming.
 */
-(void)connect;


#pragma mark - API for two callers, Publisher & Subscriber
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
@end
