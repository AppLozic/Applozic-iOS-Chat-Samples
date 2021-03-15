//
//  ALNotificationHelper.h
//  Applozic
//
//  Created by Sunil on 19/12/19.
//  Copyright © 2019 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Applozic.h"

@interface ALNotificationHelper : NSObject

-(BOOL)isApplozicViewControllerOnTop;

-(void)handlerNotificationClick:(NSString *)contactId withGroupId:(NSNumber *)groupID withConversationId:(NSNumber *)conversationId notificationTapActionDisable:(BOOL) isTapActionDisabled;

@end

