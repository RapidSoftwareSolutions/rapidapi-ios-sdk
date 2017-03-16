//
//  RapidConnect.m
//  RapidConnectSDK
//
//  Created by Andrey Bukati on 26/10/2016.
//  Copyright © 2016 RapidAPI. All rights reserved.
//

#import "RapidAPI.h"
#import <PhoenixClient/PhoenixClient.h>

@implementation RapidConnect

- (id)initWithProjectName:(NSString*)projectName andToken:(NSString*)token
{
    self = [super init];
    if (self) {
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", projectName, token];
        NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat: @"Basic %@",[authData base64EncodedStringWithOptions:0]];
        
        _baseUrl = @"https://rapidapi.io/connect";
        _auth = authValue;
        _projectName = projectName;
        _token = token;
    }
    return self;
}

- (NSString*)getBaseUrl
{
    return self.baseUrl;
}

- (NSString*)buildCallUrlWithPackage:(NSString*)package block:(NSString*)block
{
    return [NSString stringWithFormat:@"%@/%@/%@", [self getBaseUrl], package, block];
}

- (NSString*)buildGetTokenURL:(NSString*)package event:(NSString*)event
{
    return [NSString stringWithFormat:@"https://webhooks.rapidapi.com/api/get_token?user_id=%@", [self buildUserID:package event:event]];
}

- (NSString*)buildSocketURL:(NSString*)token
{
    return [NSString stringWithFormat:@"wss://webhooks.rapidapi.com/socket/websocket?token=%@", token];
}

- (NSString*)buildSocketTopic:(NSString*)token
{
    return [NSString stringWithFormat:@"users_socket:%@", token];
}

- (NSString*)buildUserID:(NSString*)package event:(NSString*)event
{
    return [NSString stringWithFormat:@"%@.%@_%@:%@", package, event, self.projectName, self.token];
}

- (void)listen:(NSString*)package
         event:(NSString*)event
withParameters:(NSDictionary*)parameters
     onMessage:(void (^)(NSDictionary *message))onMessage
       onError:(void (^)(NSDictionary *reason))onError
        onJoin:(void (^)())onJoin
       onClose:(void (^)(NSDictionary *reason))onClose
{
    NSURL *token_url = [NSURL URLWithString:[self buildGetTokenURL:package event:event]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:token_url];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSString *token = json[@"token"];
        PhxSocket *socket = [[PhxSocket alloc] initWithURL:[NSURL URLWithString:[self buildSocketURL:token]] heartbeatInterval:20];
        NSString *topic = [self buildSocketTopic:token];
        [socket connect];
        PhxChannel *channel = [[PhxChannel alloc] initWithSocket:socket topic:topic params:parameters];
        id join = [channel join];
        [join onReceive:@"ok" callback:^(id message) {
            onJoin();
        }];
        [join onReceive:@"error" callback:^(NSDictionary *reason) {
            onError(reason);
        }];
        [channel onEvent:@"new_msg" callback:^(NSDictionary *message, id ref) {
            if (!message[@"token"]) {
                onError(message[@"body"]);
            } else {
                onMessage(message[@"body"]);
            }
        }];
        [channel onClose:^(NSDictionary *reason) {
            onClose(reason);
        }];
    }] resume];
}

- (void)callPackage:(NSString*)package
              block:(NSString*)block
     withParameters:(NSDictionary*)parameters
            success:(void (^)(NSDictionary *responseDict))success
            failure:(void(^)(NSError* error))failure
{
    
    NSURL *url = [NSURL URLWithString:[self buildCallUrlWithPackage:package block:block]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"Authorization": self.auth};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField:@"Content-type"];
    
    NSMutableData *body = [NSMutableData data];
    
    for (NSString *param in parameters) {
        
        
        if([[parameters objectForKey:param] isKindOfClass:[NSString class]])
        {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
            NSString* FileParamConstant = param;
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[parameters objectForKey:param]];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSError *error = nil;
    
    if (!error) {
        NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            success(json);
            
        }];
        [uploadTask resume];
    }
    
    
}

@end
