//
//  ALContactCell.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALChannel.h"
#import "ALContact.h"
#import "ALMessage.h"

@interface ALContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView * mUserImageView;

@property (weak, nonatomic) IBOutlet UILabel *mUserNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *mMessageLabel;

@property (weak, nonatomic) IBOutlet UILabel *mTimeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *mLastMessageStatusImageView;

@property (weak, nonatomic) IBOutlet UILabel *imageNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageMarker;

@property (weak, nonatomic) IBOutlet UIImageView *onlineImageMarker;

@property (weak, nonatomic) IBOutlet UILabel *L;

@property (strong, nonatomic) IBOutlet UILabel *unreadCountLabel;

-(void)updateWithMessage:(ALMessage*) message  withColourDictionary:(NSMutableDictionary *)colourDictionary;

-(void)updateProfileImageAndUnreadCountWithChannel:(ALChannel*) alChannel orContact:(ALContact*)contact
                              withColourDictionary:(NSMutableDictionary *)colourDictionary;

-(void)displayAttachmentMediaType:(ALMessage *)message;
@end
