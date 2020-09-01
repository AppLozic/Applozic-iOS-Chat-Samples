//
//  ALContactMessageBaseCell.h
//  Applozic
//
//  Created by Sunil on 26/06/19.
//  Copyright © 2019 applozic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALMediaBaseCell.h"
#import "ALVCardClass.h"
#import "ALMessage.h"

@interface ALContactMessageBaseCell : ALMediaBaseCell

@property (nonatomic, strong) UIImageView * contactProfileImage;
@property (nonatomic, strong) UILabel * userContact;
@property (nonatomic, strong) UILabel * contactPerson;
@property (nonatomic, strong) UILabel * emailId;
@property (nonatomic, strong) UIButton * addContactButton;
@property (nonatomic) CGFloat msgFrameHeight;
@property (nonatomic, strong) ALVCardClass *vCardClass;

-(instancetype)populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize;

@end


