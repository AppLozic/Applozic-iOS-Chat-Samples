//
//  ALPushAssist.h
//  Applozic
//
//  Created by Divjyot Singh on 07/01/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALPushAssist : NSObject

@property(nonatomic, readonly, strong) UIViewController *topViewController;

-(void)assist:(NSString*)notiMsg and :(NSMutableDictionary*)dict ofUser:(NSString*)userId;
- (UIViewController*)topViewController ;
-(BOOL)isOurViewOnTop;
-(BOOL)isMessageContainerOnTop;
-(BOOL)isVOIPViewOnTop;

+ (BOOL)isViewObjIsMsgContainerVC:(UIViewController *)viewObj;

@end
