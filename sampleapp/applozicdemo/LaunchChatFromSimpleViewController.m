//
//  LaunchChatFromSimpleViewController.m
//  applozicdemo
//
//  Created by Devashish on 13/11/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "LaunchChatFromSimpleViewController.h"
#import <Applozic/ALChatViewController.h>
#import "ALChatManager.h"
#import "ApplozicLoginViewController.h"
#import <Applozic/ALUserDefaultsHandler.h>
#import <Applozic/ALRegisterUserClientService.h>
#import <Applozic/ALDBHandler.h>
#import <Applozic/ALContact.h>
#import <Applozic/ALDataNetworkConnection.h>

@interface LaunchChatFromSimpleViewController ()

- (IBAction)mLaunchChatList:(id)sender;
- (IBAction)mChatLaunchButton:(id)sender;


@end

@implementation LaunchChatFromSimpleViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [self mLaunchChatList:self];
    _activityView = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center=self.view.center;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [ALUserDefaultsHandler setUserAuthenticationTypeId:(short)APPLOZIC];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdate:) name:@"userUpdate" object:nil];
}

- (IBAction)logOutButton:(id)sender {
    
    ALRegisterUserClientService * alUserClientService = [[ALRegisterUserClientService alloc]init];
    
    if([ALUserDefaultsHandler getDeviceKeyString]){
        [alUserClientService logoutWithCompletionHandler:^(ALAPIResponse *response, NSError *error) {
            
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


//===============================================================================
// TO LAUNCH MESSAGE LIST.....
//
//===============================================================================

- (IBAction)mLaunchChatList:(id)sender {
    
    if (![ALDataNetworkConnection checkDataNetworkAvailable]){
        [_activityView removeFromSuperview];
    }
    else {
        [_activityView startAnimating];
    }
    [self.view addSubview:_activityView];
    ALUser *user = [[ALUser alloc] init];
    [user setUserId:[ALUserDefaultsHandler getUserId]];
    [user setEmail:[ALUserDefaultsHandler getEmailId]];
    [user setPassword:@""];
    
    ALChatManager * chatManager = [[ALChatManager alloc] initWithApplicationKey:@"applozic-sample-app"];
    [chatManager connectUserAndLaunchChat:user andFromController:self forUser:nil withGroupId:nil];
    
    //Adding sample contacts...
    [self insertInitialContacts];

}


//===============================================================================
// TO LAUNCH INDIVIDUAL MESSAGE LIST....
//
//===============================================================================

- (IBAction)mChatLaunchButton:(id)sender {
    
    [self.view addSubview:_activityView];
    [_activityView startAnimating];
    
    ALUser *user = [[ALUser alloc] init];
    [user setUserId:[ALUserDefaultsHandler getUserId]];
    [user setEmail:[ALUserDefaultsHandler getEmailId]];
    [user setPassword:@""];
    
    ALChatManager * chatManager = [[ALChatManager alloc] initWithApplicationKey:@"applozic-sample-app"];
    [chatManager launchChatForUserWithDisplayName:@"masteruser" withGroupId:nil andwithDisplayName:@"Master" andFromViewController:self];
    
}

//===============================================================================
// TO LAUNCH SELLER CHAT....
//
//===============================================================================

- (IBAction)launchSeller:(id)sender
{
    ALConversationProxy * newProxy = [[ALConversationProxy alloc] init];
    newProxy = [self makeupConversationDetails];
    
    ALChatManager * chatManager = [[ALChatManager alloc] initWithApplicationKey:@"applozic-sample-app"];
    [chatManager createAndLaunchChatWithSellerWithConversationProxy:newProxy fromViewController:self];
}

//===============================================================================
// Creating Conversation Details
//===============================================================================

-(ALConversationProxy * )makeupConversationDetails
{
    ALConversationProxy * alConversationProxy = [[ALConversationProxy alloc] init];
    alConversationProxy.topicId = @"laptop01";
    alConversationProxy.userId = @"adarshk";
    
    ALTopicDetail * alTopicDetail = [[ALTopicDetail alloc] init];
    alTopicDetail.title     = @"Mac Book Pro";
    alTopicDetail.subtitle  = @"13' Retina";
    alTopicDetail.link      = @"https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/macbookpro.jpg";
    alTopicDetail.key1      = @"Product ID";
    alTopicDetail.value1    = @"mac-pro-r-13";
    alTopicDetail.key2      = @"Price";
    alTopicDetail.value2    = @"Rs.1,04,999.00";
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:alTopicDetail.dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultTopicDetails = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    alConversationProxy.topicDetailJson = resultTopicDetails;
    
    return alConversationProxy;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_activityView stopAnimating];
    [_activityView removeFromSuperview];
}


- (IBAction)logoutBtn:(id)sender
{
    ALRegisterUserClientService * alUserClientService = [[ALRegisterUserClientService alloc]init];
    
    if([ALUserDefaultsHandler getDeviceKeyString])
    {
        [alUserClientService logoutWithCompletionHandler:^(ALAPIResponse *response, NSError *error) {
            
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) insertInitialContacts{
    
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    //contact 1
    ALContact *contact1 = [[ALContact alloc] init];
    contact1.userId = @"adarshk";
    contact1.fullName = @"Adarsh Kumar";
    contact1.displayName = @"Adarsh";
    contact1.email = @"github@applozic.com";
    contact1.contactImageUrl = nil;
    contact1.localImageResourceName = @"adarsh.jpg";
    
    // contact 2
    ALContact *contact2 = [[ALContact alloc] init];
    contact2.userId = @"marvel";
    contact2.fullName = @"abhishek thapliyal";
    contact2.displayName = @"abhishek";
    contact2.email = @"abhishek@applozic.com";
    contact2.contactImageUrl = nil;
    contact2.localImageResourceName = @"abhishek.jpg";
    
    
    //    Contact -------- Example with json
    
    
    NSString *jsonString =@"{\"userId\": \"applozic\",\"fullName\": \"Applozic\",\"contactNumber\": \"9535008745\",\"displayName\": \"Applozic Support\",\"contactImageUrl\": \"https://cdn-images-1.medium.com/max/800/1*RVmHoMkhO3yoRtocCRHSdw.png\",\"email\": \"devashish@applozic.com\",\"localImageResourceName\":\"sample.jpg\"}";
    ALContact *contact3 = [[ALContact alloc] initWithJSONString:jsonString];
    
    
    
    //     Contact ------- Example with dictonary
    
    
    NSMutableDictionary *demodictionary = [[NSMutableDictionary alloc] init];
    [demodictionary setValue:@"aman999" forKey:@"userId"];
    [demodictionary setValue:@"aman sharma" forKey:@"fullName"];
    [demodictionary setValue:@"75760462" forKey:@"contactNumber"];
    [demodictionary setValue:@"aman" forKey:@"displayName"];
    [demodictionary setValue:@"aman@applozic.com" forKey:@"email"];
    [demodictionary setValue:@"http://images.landofnod.com/is/image/LandOfNod/Letter_Giant_Enough_A_231533_LL/$web_zoom$&wid=550&hei=550&/1308310656/not-giant-enough-letter-a.jpg" forKey:@"contactImageUrl"];
    [demodictionary setValue:nil forKey:@"localImageResourceName"];
    [demodictionary setValue:[ALUserDefaultsHandler getApplicationKey] forKey:@"applicationId"];
    
    ALContact *contact4 = [[ALContact alloc] initWithDict:demodictionary];
    [theDBHandler addListOfContacts:@[contact1, contact2, contact3, contact4]];
    
}

-(void)userUpdate:(NSNotification*)userDetails
{
    ALUserDetail * user = userDetails.object;
    if(user.connected)
    {
        //NSLog(@"USER_ONLINE:\nName%@\nID:%@",user.displayName,user.userId);
    }
    else{
        //        NSLog(@"USER_OFFLINE:\nName%@\nID:%@",user.displayName,user.userId);
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:@"userUpdate"];
}

@end
