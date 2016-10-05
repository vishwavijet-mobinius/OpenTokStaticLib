//
//  OpenTokInitializer.m
//  OpenTokStaticLib
//
//  Created by vishwavijet on 9/30/16.
//  Copyright © 2016 mobinius.com. All rights reserved.
//

#import "OpenTokInitializer.h"

static OpenTokInitializer *sharedInstance = nil;
@implementation OpenTokInitializer

+(void)initialize{
    static dispatch_once_t globalInstance = nil;
    dispatch_once(&globalInstance, ^{
        sharedInstance = [[OpenTokInitializer alloc] init];
    });
}

+(OpenTokInitializer *)sharedInstance{
    return sharedInstance;
}


-(void)intializeWithURL:(NSString *)urlString withRequest:(NSDictionary *)request withCompletionHandler:(void(^)(NSError *error))CompletionHandler
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:300];
    urlRequest.HTTPMethod = @"POST";
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:request options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
    {
        return;
    }
    urlRequest.HTTPBody = data;
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *session = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            NSError *jsonError = nil;
            NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            NSDictionary *credentials = [responseDict valueForKey:@"data"];
            
            OTSession *session = [[OTSession alloc] initWithApiKey:credentials[@"apiKey"] sessionId:credentials[@"sessionId"] delegate:_openTokDelegate];
            OTError *connectError;
            [session connectWithToken:credentials[@"token"] error:&connectError];
            
            //CompletionHandler(session,nil);
        }
        else{
            CompletionHandler(error);
        }
    }];
    [session resume];
}


-(void)sessionDidConnect:(OTSession *)session{
    if ([self.openTokDelegate respondsToSelector:@selector(openTokSesionConnectedWithSession:)]){
        [self.openTokDelegate performSelector:@selector(openTokSesionConnectedWithSession:) withObject:session];
    }
}


-(void)sessionDidDisconnect:(OTSession *)session{
    
}
@end
