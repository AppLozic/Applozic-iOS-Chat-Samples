//
//  ALChatViewController.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//
#import "ALMapViewController.h"
#import <UIKit/UIKit.h>
#import "ALBaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ALChatCell.h"
#import "ALAudioCell.h"
#import "ALAudioAttachmentViewController.h"
#import "ALVCardClass.h"
#import <ContactsUI/CNContactPickerViewController.h>
#import "ALNewContactsViewController.h"
#import <ApplozicCore/ApplozicCore.h>

extern NSString * const ThirdPartyDetailVCNotification;
extern NSString * const ThirdPartyDetailVCNotificationNavigationVC;
extern NSString * const ThirdPartyDetailVCNotificationALContact;
extern NSString * const ThirdPartyDetailVCNotificationChannelKey;
extern NSString * const ThirdPartyProfileTapNotification;

extern NSString * const ALAudioVideoCallForUserIdKey;
extern NSString * const ALCallForAudioKey;
extern NSString * const ALDidSelectStartCallOptionKey;

@protocol ALChatViewControllerDelegate <NSObject>

@optional
-(void)handleCustomActionFromChatVC:(UIViewController *)chatViewController andWithMessage:(ALMessage *)alMessage;

@end

@interface ALChatViewController : ALBaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ALMapViewControllerDelegate,ALChatCellDelegate,CNContactPickerDelegate,ALForwardMessageDelegate>

@property (strong, nonatomic) ALContact * alContact;
@property (nonatomic, strong) ALChannel * alChannel;
@property (strong, nonatomic) ALMessageArrayWrapper * alMessageWrapper;
@property (strong, nonatomic) NSMutableArray * mMessageListArrayKeyStrings;
@property (strong, nonatomic) NSString * contactIds;
@property (nonatomic, strong) NSNumber * channelKey;
@property (nonatomic, strong) NSString * channelName;
@property (nonatomic, strong) NSNumber * conversationId;
@property (strong, nonatomic) ALMessage * alMessage;
@property (nonatomic, strong) NSString * contactsGroupId;
@property (nonatomic) BOOL isSearch;

@property (nonatomic) BOOL isVisible;

@property (nonatomic) BOOL refresh;
@property (strong, nonatomic) NSString * displayName;

@property (strong, nonatomic) NSString * text;
@property (nonatomic) double defaultMessageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomToAttachment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop2Constraint;

@property (weak, nonatomic) id <ALChatViewControllerDelegate> chatViewDelegate;

-(void)fetchAndRefresh;
-(void)fetchAndRefresh:(BOOL)flag;
-(void)refreshViewOnNotificationTap:(NSString *)userId withChannelKey:(NSNumber *)channelKey withConversationId:(NSNumber *)conversationId;

-(void)updateDeliveryReport:(NSString*)key withStatus:(int)status;
-(void)updateStatusReportForConversation:(int)status;
-(void)individualNotificationhandler:(NSNotification *) notification;

-(void)updateDeliveryStatus:(NSNotification *) notification;
-(void) updateConversationProfileDetails;

//-(void) syncCall:(NSString *) contactId updateUI:(NSNumber *) updateUI alertValue: (NSString *) alertValue;
-(void) syncCall:(ALMessage *) alMessage andMessageList:(NSMutableArray*)messageArray;
-(void)showTypingLabel:(BOOL)flag userId:(NSString *)userId;
-(void)subProcessTextViewDidChange:(UITextView *)textView;

-(void) updateLastSeenAtStatus: (ALUserDetail *) alUserDetail;
-(void) reloadViewfor3rdParty;
-(void) reloadView;

-(void)markConversationRead;
-(void)markSingleMessageRead:(ALMessage *)almessage;

-(void)handleNotification:(UIGestureRecognizer*)gestureRecognizer;

//-(void)googleImage:(UIImage*)staticImage withURL:(NSString *)googleMapUrl withCompletion:(void(^)(NSString *message, NSError *error))completion;

-(void) syncCall:(ALMessage*)AlMessage  updateUI:(NSNumber *)updateUI alertValue: (NSString *)alertValue;
-(void)serverCallForLastSeen;
-(void)loadMessagesWithStarting:(BOOL)loadFromStart WithScrollToBottom:(BOOL)flag withNextPage:(BOOL)isNextPage;
-(NSString*)formatDateTime:(ALUserDetail*)alUserDetail  andValue:(double)value;
-(void)checkUserBlockStatus;
-(void)updateChannelSubscribing:(NSNumber *)oldChannelKey andNewChannel:(NSNumber *)newChannelKey;
-(void)subProcessDetailUpdate:(ALUserDetail *)userId;

-(void)subscrbingChannel;
-(void)unSubscrbingChannel;

-(void)postMessage;
@end
