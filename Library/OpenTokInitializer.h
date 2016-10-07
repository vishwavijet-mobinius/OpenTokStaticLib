//
//  OpenTokInitializer.h
//  OpenTokStaticLib
//
//  Created by vishwavijet on 9/30/16.
//  Copyright © 2016 mobinius.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenTokInitializer : NSObject

+(OpenTokInitializer *)sharedInstance;

-(void)intializeWithURL:(NSString *)urlString withRequest:(NSDictionary *)request withCompletionHandler:(void(^)(NSDictionary *response, NSError *error))CompletionHandler;

@end



