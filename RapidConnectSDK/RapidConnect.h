//
//  RapidConnect.h
//  RapidConnectSDK
//
//  Created by Andrey Bukati on 26/10/2016.
//  Copyright © 2016 RapidAPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RapidConnect : NSObject

@property (nonatomic, assign) NSString* baseUrl;
@property (nonatomic, assign) NSString* auth;


- (id)initWithProjectName:(NSString*)projectName andToken:(NSString*)token;
- (void)callPackage:(NSString*)package
              block:(NSString*)block
     withParameters:(NSDictionary*)parameters
            success:(void (^)(NSDictionary *responseDict))success
            failure:(void(^)(NSError* error))failure;

@end
