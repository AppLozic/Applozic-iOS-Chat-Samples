//
//  ApplozicLoginViewController.m
//  applozicdemo
//
//  Created by Devashish on 08/10/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ApplozicLoginViewController.h"
#import <Applozic/ALUser.h>
#import <Applozic/ALUserDefaultsHandler.h>
#import <Applozic/ALMessageClientService.h>
#import <Applozic/ALRegistrationResponse.h>
#import <Applozic/ALRegisterUserClientService.h>
#import <Applozic/ALMessagesViewController.h>
#import <Applozic/ALApplozicSettings.h>
#import <Applozic/ALDataNetworkConnection.h>
#import <Applozic/ALChatLauncher.h>
#import <Applozic/ALMessageDBService.h>
#import "ALChatManager.h"
#import "LaunchChatFromSimpleViewController.h"

@interface ApplozicLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIdField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *getStarted;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;
- (IBAction)launchTabBar:(id)sender;

@end

@implementation ApplozicLoginViewController


//-------------------------------------------------------------------------------------------------------------------
//      View lifecycle
//-------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    //[ self registerForNotification];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewWillAppear:(BOOL)animated {
    //    if (![ALUserDefaultsHandler getApnDeviceToken]){
    //        [ self registerForNotification];
    //    }
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
    [ALDataNetworkConnection checkDataNetworkAvailable];
    [self.mActivityIndicator stopAnimating];
    [self setTitle:@"Log Out"];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = self.getStarted.frame.origin;
    
    CGFloat buttonHeight = self.getStarted.frame.size.height;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

//-------------------------------------------------------------------------------------------------------------------
//      IBAction func
//-------------------------------------------------------------------------------------------------------------------

- (IBAction)login:(id)sender {
    
//    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
//    [registerUserClientService logout];
    // Initial login view .....
    
    
    
    NSString *message = [[NSString alloc] initWithFormat: @"Hello %@", [self.userIdField text]];
    NSLog(@"message: %@", message);
    
    if (self.userIdField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  @"Error" message:@"UserId can't be blank" delegate:self
                                                 cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
        return;
    }
    
    //
    ALUser * user = [[ALUser alloc] init];
    [user setUserId:[self.userIdField text]];
    [user setEmail:[self.emailField text]];
    [user setPassword:[self.passwordField text]];
    [user setImageLink:@""];
    [self.mActivityIndicator startAnimating];
    
    [ALUserDefaultsHandler setUserId:user.userId];
    [ALUserDefaultsHandler setEmailId:user.email];
    [ALUserDefaultsHandler setPassword:user.password];
    [ALUserDefaultsHandler setUserAuthenticationTypeId:(short)APPLOZIC];
    
    ALChatManager * chatManager = [[ALChatManager alloc] initWithApplicationKey:@"applozic-sample-app"];
    [chatManager connectUser:user];
    
    UIStoryboard* storyboardM = [UIStoryboard storyboardWithName:@"Main"
                                                          bundle:nil];
    UIViewController *launchChat = [storyboardM instantiateViewControllerWithIdentifier:@"LaunchChatFromSimpleViewController"];
    [self presentViewController:launchChat animated:YES completion:nil];
    
    
}

//-------------------------------------------------------------------------------------------------------------------
//     Textfield delegate methods
//-------------------------------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userIdField) {
        [self.emailField becomeFirstResponder];
    }
    else if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    }
    else {
        //TODO: Also validate user Id and email is entered.
        [textField resignFirstResponder];
    }
    return true;
}

//==================================================================================
// LAUNCH VIA TAB BAR (USING CONTAINER VIEW)
//==================================================================================

- (IBAction)launchTabBar:(id)sender
{
    
    if (!self.userIdField.text.length || !self.passwordField.text.length)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error"
                                                           message:@"UserId/Password can't be blank"
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"Ok", nil];
        [alertView show];
        return;
    }
    
    ALUser * user = [[ALUser alloc] init];
    [user setUserId:[self.userIdField text]];
    [user setEmail:[self.emailField text]];
    [user setPassword:[self.passwordField text]];
    
    [self.mActivityIndicator startAnimating];
    
    [ALUserDefaultsHandler setUserId:user.userId];
    [ALUserDefaultsHandler setEmailId:user.email];
    [ALUserDefaultsHandler setPassword:user.password];
    [ALUserDefaultsHandler setUserAuthenticationTypeId:(short)APPLOZIC];
    
    ALChatManager * chatManager = [[ALChatManager alloc] initWithApplicationKey:@"applozic-sample-app"];
    [chatManager connectUserWithCompletion:user withHandler:^(ALRegistrationResponse *rResponse, NSError *error) {
        
        [self launchChatListViaTabBar];
    }];
}

-(void)launchChatListViaTabBar
{
    UIStoryboard *storyboardM = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    UITabBarController *tabBar = [storyboardM instantiateViewControllerWithIdentifier:@"ALTabBarController"];
    //    UINavigationController *navBar = [tabBar.viewControllers objectAtIndex:0];
    //    UIViewController *launchChat = [navBar.viewControllers objectAtIndex:0];
    
    UIViewController *launchChatViaTabBar = [storyboardM instantiateViewControllerWithIdentifier:@"ALTabBarController"];
    [self presentViewController:launchChatViaTabBar animated:YES completion:nil];
}

@end
