//
//  ALMQTTConversationService.h
//  Applozic
//
//  Created by Applozic Inc on 11/27/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTClient.h"
#import "ALMessage.h"
#import "ALUserDetail.h"
#import "ALSyncCallService.h"
#import "ALUserDetail.h"
#import "ALRealTimeUpdate.h"

extern NSString *const ALChannelDidChangeGroupMuteNotification;
extern NSString *const ALLoggedInUserDidChangeDeactivateNotification;
extern NSString *const AL_MESSAGE_STATUS_TOPIC;

@protocol ALMQTTConversationDelegate <NSObject>

-(void) syncCall:(ALMessage *) alMessage andMessageList:(NSMutableArray *)messageArray;
-(void) delivered:(NSString *) messageKey contactId:(NSString *)contactId withStatus:(int)status;
-(void) updateStatusForContact:(NSString *)contactId  withStatus:(int)status;
-(void) updateTypingStatus: (NSString *) applicationKey userId: (NSString *) userId status: (BOOL) status;
-(void) updateLastSeenAtStatus: (ALUserDetail *) alUserDetail;
-(void) mqttConnectionClosed;

@optional

-(void) mqttDidConnected;
-(void) reloadDataForUserBlockNotification:(NSString *)userId andBlockFlag:(BOOL)flag;
-(void)updateUserDetail:(NSString *)userId;

@end


@interface ALMQTTConversationService : NSObject <MQTTSessionDelegate>

+(ALMQTTConversationService *)sharedInstance;

@property (nonatomic, strong) ALSyncCallService *alSyncCallService;

@property (nonatomic, weak) id<ALMQTTConversationDelegate>mqttConversationDelegate;

@property (nonatomic, weak) id<ApplozicUpdatesDelegate>realTimeUpdate;

@property (nonatomic, readwrite) MQTTSession *session;

-(void) subscribeToConversation;
-(void) subscribeToConversationWithTopic:(NSString *) topic;

-(void) unsubscribeToConversation;
-(void) unsubscribeToConversationWithTopic:(NSString *) topic;

-(BOOL) unsubscribeToConversation: (NSString *)userKey;

-(void) sendTypingStatus:(NSString *) applicationKey userID:(NSString *) userId andChannelKey:(NSNumber *)channelKey typing: (BOOL) typing;

-(void)unSubscribeToChannelConversation:(NSNumber *)channelKey;
-(void)subscribeToChannelConversation:(NSNumber *)channelKey;

-(void)subscribeToOpenChannel:(NSNumber *)channelKey;
-(void)unSubscribeToOpenChannel:(NSNumber *)channelKey;
-(void) syncReceivedMessage :(ALMessage *)alMessage withNSMutableDictionary:(NSMutableDictionary*)nsMutableDictionary;

-(void) retryConnection;
-(void) retryConnectionWithTopic:(NSString *)topic;

-(void)subscribeToConversationWithTopic:(NSString *)topic withCompletionHandler:(void (^)(BOOL subscribed, NSError * error))completion;

/// For publishing a read status of message using MQTT
/// @param messageKey Pass the messageKey which is used for identifiying the message.
-(BOOL) messageReadStatusPublishWithMessageKey:(NSString *) messageKey;

/// For publishing custom data with topic using MQTT
/// @param dataString Pass the string of data to publish.
/// @param topic Pass the topic name to publish on.
-(BOOL) publishCustomData:(NSString *)dataString withTopicName:(NSString *) topic;
@end
