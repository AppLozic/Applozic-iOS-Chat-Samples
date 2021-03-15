//
//  ALAudioVideoBaseVC.h
//  Applozic
//
//  Created by Abhishek Thapliyal on 1/12/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

static BOOL chatRoomEngage;

typedef enum {
    AV_CALL_DIALLED = 0,
    AV_CALL_RECEIVED = 1
}AV_LAUNCH_OPTIONS;

@interface ALAudioVideoBaseVC : UIViewController

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSNumber *launchFor;
@property (nonatomic, strong) NSString *baseRoomId;
@property (nonatomic) BOOL callForAudio;

+(BOOL)chatRoomEngage;
+(void)setChatRoomEngage:(BOOL)flag;
-(void)dismissAVViewController:(BOOL)animated;
-(void)handleDataConnectivity;

@end
