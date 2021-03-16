//
//  ChatOptionVC.m
//  ApplozicCocoaPodDemo
//
//  Created by Abhishek Thapliyal on 9/9/16.
//  Copyright © 2016 Abhishek Thapliyal. All rights reserved.
//

#import "ChatOptionVC.h"

@interface ChatOptionVC ()

- (IBAction)LaunchIndividualChat:(id)sender;
- (IBAction)LaunchContextualChat:(id)sender;
- (IBAction)LaunchMsgList:(id)sender;
- (IBAction)logoutAction:(id)sender;

@end

@implementation ChatOptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (IBAction)LaunchMsgList:(id)sender
{
    ALChatManager *manager = [[ALChatManager alloc] initWithApplicationKey:@"applozic-sample-app"]; // SET APPLICATION ID

    ALUser *user = [[ALUser alloc] init];
    [user setUserId:[ALUserDefaultsHandler getUserId]];
    [user setEmail:[ALUserDefaultsHandler getEmailId]];
    [manager connectUserAndLaunchChat:user andFromController:self forUser:nil withGroupId:nil];
}

- (IBAction)LaunchIndividualChat:(id)sender
{
    ALChatManager *manager = [[ALChatManager alloc] initWithApplicationKey:@"applozic-sample-app"]; // SET APPLICATION ID
    [manager launchChatForUserWithDisplayName:@"user101" withGroupId:nil andwithDisplayName:@"USER 101" andFromViewController:self];
}

- (IBAction)LaunchContextualChat:(id)sender
{

}


- (IBAction)logoutAction:(id)sender
{
    ALRegisterUserClientService * userClient = [ALRegisterUserClientService new];
    if([ALUserDefaultsHandler getDeviceKeyString])
    {
        [userClient logoutWithCompletionHandler:^(ALAPIResponse *response, NSError *error) {
            
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
