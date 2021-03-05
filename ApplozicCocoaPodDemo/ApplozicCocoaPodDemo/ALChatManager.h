//
//  ALChatManager.h
//  applozicdemo
//
//  Created by Devashish on 28/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Applozic/ALChatLauncher.h>
#import <ApplozicCore/ApplozicCore.h>

static NSString *const APPLICATION_ID = @"applozic-sample-app";

@interface ALChatManager : NSObject

@property(nonatomic,strong) ALChatLauncher * chatLauncher;

@property(nonatomic,strong) NSArray * permissableVCList;

-(instancetype)initWithApplicationKey:(NSString *)applicationKey;

-(void)connectUser:(ALUser * )alUser;

-(void)connectUserWithCompletion:(ALUser *)alUser withHandler:(void(^)(ALRegistrationResponse *rResponse, NSError *error))completion;

@property (nonatomic,retain) NSString * userID;

-(void)launchChat: (UIViewController *)fromViewController;

-(void)launchChatForUserWithDefaultText:(NSString * )userId andFromViewController:(UIViewController*)viewController;

-(void)connectUserAndLaunchChat:(ALUser *)alUser andFromController:(UIViewController*)viewController forUser:(NSString*)userId withGroupId:(NSNumber*)groupID;

-(void)launchChatForUserWithDisplayName:(NSString * )userId withGroupId:(NSNumber*)groupID andwithDisplayName:(NSString*)displayName andFromViewController:(UIViewController*)fromViewController;

-(void)createAndLaunchChatWithSellerWithConversationProxy:(ALConversationProxy*)alConversationProxy fromViewController:(UIViewController*)fromViewController;

-(void)launchListWithUserORGroup: (NSString *)userId ORWithGroupID: (NSNumber *)groupId andFromViewController:(UIViewController*)fromViewController;

-(void)launchOpenGroupWithKey:(NSNumber *)channelKey fromViewController:(UIViewController *)viewController;

-(BOOL)isUserHaveMessages:(NSString *)userId;

-(void) launchContactScreenWithMessage:(ALMessage *)alMessage andFromViewController:(UIViewController*)viewController;

-(NSString *)getApplicationKey;

-(void)launchChatListWithParentKey:(NSNumber *)parentGroupKey andFromViewController:(UIViewController *)viewController;

-(void)launchGroupOfTwoWithClientId:(NSString *)userIdOfReceiver
                         withItemId:(NSString *)itemId
                       withMetaData:(NSMutableDictionary *)metadata
                        andWithUser:(NSString *)userId
              andFromViewController:(UIViewController *)viewController;

@end
