//
//  ALMediaBaseCell.h
//  Applozic
//
//  Created by devashish on 19/02/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//
/***************************************************************************************
 TABLE CELL CUSTOM BASE CLASS : THIS CLASS IS A BASE CLASS FOR ALL MEDIA TYPE MESSAGES
 i.e IMAGE, VIDEO, DOCUMENT, AUDIO, LOCATION & CONTACT
 ***************************************************************************************/


#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALUIConstant.h"
#import "MessageReplyView.h"
#import <AVKit/AVKit.h>
#import "ALTappableView.h"
#import <ApplozicCore/ApplozicCore.h>

@protocol ALMediaBaseCellDelegate <NSObject>

-(void) downloadRetryButtonActionDelegate:(int) index andMessage:(ALMessage *) message;
-(void) thumbnailDownloadWithMessageObject:(ALMessage *) message;
-(void) stopDownloadForIndex:(int)index andMessage:(ALMessage *)message;
-(void) showImagePreviewWithFilePath:(NSString *) filePath;
-(void) deleteMessageFromView:(ALMessage *)message;
-(void) loadViewForMedia:(UIViewController *)launch;
-(void) showVideoFullScreen:(AVPlayerViewController *)fullView;
-(void) showSuggestionView:(NSURL *)fileURL andFrame:(CGRect)frame;
-(void) showAnimationForMsgInfo:(BOOL)flag;
-(void) processTapGesture:(ALMessage *)alMessage;
-(void) processForwardMessage:(ALMessage *) message;
-(void) handleTapGestureForKeyBoard;
-(void) deleteMessasgeforAll:(ALMessage *) message;
-(void)messageReport:(ALMessage *)alMessage;

@optional

-(void)openUserChat:(ALMessage *)alMessage;
-(void) processUserChatView:(ALMessage *)alMessage;
-(void) processMessageReply:(ALMessage *) message;
-(void) scrollToReplyMessage:(ALMessage *)alMessage;

@end

@interface ALMediaBaseCell : UITableViewCell <KAProgressLabelDelegate>

@property (retain, nonatomic) UIImageView * mImageView;
@property (retain, nonatomic) UILabel *mDateLabel;
@property (nonatomic, retain) UIImageView * mBubleImageView;
@property (nonatomic, retain) UIImageView * mUserProfileImageView;
@property (retain, nonatomic) UILabel *mNameLabel;
@property (nonatomic, retain) ALMessage * mMessage;
@property (nonatomic, retain) UIImageView *mMessageStatusImageView;
@property (nonatomic, retain) UIButton * mDowloadRetryButton;
@property (nonatomic, retain) KAProgressLabel *progresLabel;
@property (nonatomic, strong) UITextView *imageWithText;
@property (retain, nonatomic) UILabel *mChannelMemberName;
@property (retain, retain) UIView * replyParentView;
@property (strong, nonatomic)  NSMutableDictionary *alphabetiColorCodesDictionary;

@property (nonatomic, strong) ALTappableView * frontView;

@property (nonatomic, assign) id <ALMediaBaseCellDelegate> delegate;

@property (strong, nonatomic) UILongPressGestureRecognizer * menuTapGesture;

-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;
@property (retain, nonatomic) MessageReplyView * replyUIView;
-(void)setupProgress;
-(void)dowloadRetryButtonAction;
-(void)hidePlayButtonOnUploading;
-(void)openUserChatVC;
-(void)processReplyOfChat:(ALMessage*)almessage andViewSize:(CGSize)viewSize;
-(NSString *)getMessageStatusIconName:(ALMessage *)alMessage;

@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIView *downloadRetryView;
-(BOOL)isMessageReplyMenuEnabled:(SEL) action;

@property (nonatomic, strong) ALChannel * channel;
@end
