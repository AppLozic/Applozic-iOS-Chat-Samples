//
//  ALRegisterUserClientService.h
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ALRegistrationResponse.h"
#import "ALUser.h"
#import "ALConstant.h"
#import "ALAPIResponse.h"

static NSString *const AL_INVALID_APPLICATIONID = @"INVALID_APPLICATIONID";
static short AL_VERSION_CODE = 112;
static NSString *const AL_LOGOUT_URL = @"/rest/ws/device/logout";

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

/// This method is used for updating APNs and VOIP token to applozic server if both tokens are exists
/// If either one of token doesn't exist it will store in user defaults for future use
/// @param apnsOrVoipDeviceToken Pass APNs or VOIP token.
/// @param isAPNsToken Pass YES in case of APNs token, NO in case of VOIP token.
/// @param completion will trigger in case if any success or error.

-(void)updateAPNsOrVOIPDeviceToken:(NSString *)apnsOrVoipDeviceToken
                  withApnTokenFlag:(BOOL) isAPNsToken
                    withCompletion:(void(^)(ALRegistrationResponse * response, NSError *error)) completion;

/// This method is used for accessing currently stored APN's Or APN's and VOIP device token
-(NSString *)getRegistrationId;
@end
