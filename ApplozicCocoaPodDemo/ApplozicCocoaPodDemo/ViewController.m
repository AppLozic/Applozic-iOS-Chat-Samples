//
//  ViewController.m
//  ApplozicCocoaPodDemo
//
//  Created by Abhishek Thapliyal on 9/8/16.
//  Copyright © 2016 Abhishek Thapliyal. All rights reserved.
//

#import "ViewController.h"
#import "ALChatManager.h"
#import <Applozic/Applozic.h>
#import "ChatOptionVC.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIdTxtField;
@property (weak, nonatomic) IBOutlet UITextField *emailTxtField;
@property (weak, nonatomic) IBOutlet UITextField *paswordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginAction:(id)sender
{
    
    if(!self.userIdTxtField.text.length || !self.paswordField.text.length)
    {
        [ALUIUtilityClass showAlertMessage:@"Invalid userId/Password" andTitle:@"Oops!!!"];
        return;
    }
    
    [self.activityIndicator startAnimating];
    ALUser *user = [ALUser new];
    
    user.userId = self.userIdTxtField.text;
    user.password = self.paswordField.text;
    user.email = self.emailTxtField.text;
    
    [ALUserDefaultsHandler setUserId:user.userId];
    [ALUserDefaultsHandler setPassword:user.password];
    [ALUserDefaultsHandler setEmailId:user.email];
    
    ALChatManager *manager = [[ALChatManager alloc] initWithApplicationKey:@"applozic-sample-app"]; // SET APPLICATION ID
    [manager connectUserWithCompletion:user withHandler:^(ALRegistrationResponse *rResponse, NSError *error) {

        if (!error) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatOptionVC * chatOptionVC = [storyBoard instantiateViewControllerWithIdentifier:@"ChatOptionVC"];

            chatOptionVC.alUser = user;
            [self.activityIndicator stopAnimating];
            [self presentViewController:chatOptionVC animated:YES completion:nil];
        } else {
            NSLog(@"Failed to login");
        }
    }];
}


@end
