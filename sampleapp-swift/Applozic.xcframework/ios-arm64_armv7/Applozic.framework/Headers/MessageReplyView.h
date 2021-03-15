//
//  MessageReplyView.h
//  Applozic
//
//  Created by Adarsh Kumar Mishra on 4/21/17.
//  Copyright © 2017 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ApplozicCore/ApplozicCore.h>

@interface MessageReplyView : UIView

@property (retain, nonatomic) IBOutlet UILabel *contactName;

@property (retain, nonatomic) IBOutlet UILabel *replyMessageText;
@property (retain, nonatomic) IBOutlet UIImageView *attachmentImage;

-(UIView*)populateUI:(ALMessage*)alMessage withSuperView:(UIView*)superView;
-(CGFloat)getWidthRequired:(ALMessage*)alMessage andViewSize:(CGSize)viewSize;

@end
