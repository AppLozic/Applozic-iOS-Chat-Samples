//
//  ALChatCell.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ApplozicCore/ApplozicCore.h>
#import "ALChatCell.h"

@interface ALCustomCell : ALChatCell
-(instancetype)populateCell:(ALMessage*) alMessage viewSize:(CGSize)viewSize;
@end
