//
//  ALAttachmentService.h
//  Applozic
//
//  Created by sunil on 25/09/18.
//  Copyright © 2018 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALConnection.h"
#import "ALConnectionQueueHandler.h"
#import "ALMessageDBService.h"
#import "ALMessage.h"
#import "ALMessageService.h"
#import "ALRealTimeUpdate.h"
#import "ApplozicClient.h"


NS_ASSUME_NONNULL_BEGIN

@interface ALAttachmentService : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong) id<ApplozicAttachmentDelegate>attachmentProgressDelegate;
@property (nonatomic, strong) id<ApplozicUpdatesDelegate> delegate;

+(ALAttachmentService *)sharedInstance;

-(void)sendMessageWithAttachment:(ALMessage*) attachmentMessage withDelegate:(id<ApplozicUpdatesDelegate>) delegate withAttachmentDelegate:(id<ApplozicAttachmentDelegate>)attachmentProgressDelegate;

-(void) downloadMessageAttachment:(ALMessage*)alMessage withDelegate:(id<ApplozicAttachmentDelegate>)attachmentProgressDelegate;

@end

NS_ASSUME_NONNULL_END
