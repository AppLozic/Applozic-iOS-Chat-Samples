//
//  ALRegisterUserClientService.h
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//
static NSString *const AL_INVALID_APPLICATIONID = @"INVALID_APPLICATIONID";
static short AL_VERSION_CODE = 112;
static NSString *const AL_LOGOUT_URL = @"/rest/ws/device/logout";

#import <Foundation/Foundation.h>
#import "ALRegistrationResponse.h"
#import "ALUser.h"
#import "ALConstant.h"
#import "ALAPIResponse.h"

@interface ALRegisterUserClientService : NSObject

-(void) initWithCompletion:(ALUser *)user withCompletion:(void(^)(ALRegistrationResponse * message, NSError * error)) completion;

-(void) updateApnDeviceTokenWithCompletion:(NSString *)apnDeviceToken withCompletion:(void(^)(ALRegistrationResponse * message, NSError * error)) completion;

+(void) updateNotificationMode:(short)notificationMode withCompletion:(void(^)(ALRegistrationResponse * response, NSError *error)) completion;
-(void) connect;

-(void) disconnect;

-(void)logoutWithCompletionHandler:(void(^)(ALAPIResponse *response, NSError *error))completion;

+(BOOL)isAppUpdated;

-(void)syncAccountStatus;

-(void)syncAccountStatusWithCompletion:(void(^)(ALRegistrationResponse * response, NSError *error)) completion;

-(void)updateUser:(ALUser *)alUser withCompletion:(void(^)(ALRegistrationResponse * response, NSError *error)) completion;
@end
