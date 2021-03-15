//
//  ALPushNotificationService.h
//  ChatApp
//
//  Created by devashish on 28/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

// NEW CODES FOR VERSION CODE 105...

typedef enum
{
    AL_SYNC = 0,
    AL_DELIVERED,
    AL_DELETE_MESSAGE,
    AL_CONVERSATION_DELETED,
    AL_MESSAGE_READ,
    AL_MESSAGE_DELIVERED_AND_READ,
    AL_CONVERSATION_READ,
    AL_CONVERSATION_DELIVERED_AND_READ,
    AL_USER_CONNECTED,
    AL_USER_DISCONNECTED,
    AL_MESSAGE_SENT,
    AL_USER_BLOCK,
    AL_USER_UNBLOCK,
    AL_TEST_NOTIFICATION,
    AL_MTEXTER_USER,
    AL_CONTACT_VERIFIED,
    AL_DEVICE_CONTACT_SYNC,
    AL_MT_EMAIL_VERIFIED,
    AL_DEVICE_CONTACT_MESSAGE,
    AL_CANCEL_CALL,
    AL_MESSAGE,
    AL_DELETE_MULTIPLE_MESSAGE,
    AL_SYNC_PENDING,
    AL_GROUP_CONVERSATION_READ,
    AL_USER_MUTE_NOTIFICATION,
    AL_USER_DETAIL_CHANGED,
    AL_USER_DELETE_NOTIFICATION,
    AL_GROUP_CONVERSATION_DELETED,
    AL_CONVERSATION_DELETED_NEW,
    AL_MESSAGE_METADATA_UPDATE,
    AL_NOTFICATION_COUNT,
    AL_GROUP_MUTE_NOTIFICATION,
    AL_USER_ACTIVATED,
    AL_USER_DEACTIVATED
} AL_PUSH_NOTIFICATION_TYPE;

#import <Foundation/Foundation.h>
#import "ALMessage.h"
#import "ALUserDetail.h"
#import "ALSyncCallService.h"
#import "ALMQTTConversationService.h"
#import "ALRealTimeUpdate.h"

static NSString *const APPLOZIC_PREFIX = @"APPLOZIC_";
static NSString *const APPLOZIC_CATEGORY_KEY = @"category";

@interface ALPushNotificationService : NSObject

-(BOOL) isApplozicNotification: (NSDictionary *) dictionary;

@property (nonatomic, weak) id<ApplozicUpdatesDelegate>realTimeUpdate;

-(BOOL) processPushNotification: (NSDictionary *) dictionary updateUI: (NSNumber*) updateUI;

@property(nonatomic,strong) ALSyncCallService * alSyncCallService;

@property(nonatomic, readonly, strong) UIViewController *topViewController;

-(void)notificationArrivedToApplication:(UIApplication*)application withDictionary:(NSDictionary *)userInfo;
+(void)applicationEntersForeground;
+(void)userSync;
-(BOOL) checkForLaunchNotification:(NSDictionary *)dictionary;
-(NSDictionary *)notificationTypes;
@end
