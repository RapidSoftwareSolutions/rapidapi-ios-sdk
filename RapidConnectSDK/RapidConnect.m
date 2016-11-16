//
//  RapidConnect.m
//  RapidConnectSDK
//
//  Created by Andrey Bukati on 26/10/2016.
//  Copyright © 2016 RapidAPI. All rights reserved.
//

#import "RapidConnect.h"

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
