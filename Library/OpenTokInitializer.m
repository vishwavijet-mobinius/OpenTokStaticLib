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
    static dispatch_once_t globalInstance;
    dispatch_once(&globalInstance, ^{
        sharedInstance = [[OpenTokInitializer alloc] init];
    });
}

+(OpenTokInitializer *)sharedInstance{
    return sharedInstance;
}


-(void)intializeWithURL:(NSString *)urlString withRequest:(NSDictionary *)request withCompletionHandler:(void(^)(NSDictionary *response, NSError *error))CompletionHandler
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:300];
    urlRequest.HTTPMethod = @"PUT";
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
            CompletionHandler(responseDict,nil);
        }
        else{
            CompletionHandler(nil,error);
        }
    }];
    [session resume];
}
@end
