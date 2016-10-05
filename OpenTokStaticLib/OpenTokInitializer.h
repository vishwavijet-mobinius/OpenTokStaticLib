//
//  OpenTokInitializer.h
//  OpenTokStaticLib
//
//  Created by vishwavijet on 9/30/16.
//  Copyright © 2016 mobinius.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>

@interface OpenTokInitializer : NSObject <OTSessionDelegate>

+(OpenTokInitializer *)sharedInstance;

@property(nonatomic, assign) id<OTSessionDelegate> openTokDelegate;

-(void)intializeWithURL:(NSString *)urlString withRequest:(NSDictionary *)request withCompletionHandler:(void(^)(NSError *error))CompletionHandler;

//-(void)createSessionWithName:(NSString *)name withCode:(NSString *)code forURL:(NSString *)URL withCompletion:(void(^)(NSDictionary *response, NSError *error))CompletionHandler;

@end


@protocol OpenTokInitializerDelegate <NSObject>

-(void)openTokSesionConnectedWithSession:(OTSession *)session;

@end