//
//  AppDelegate.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "AppDelegate.h"
#import <Applozic/ALUserDefaultsHandler.h>
#import <Applozic/ALRegisterUserClientService.h>
#import <Applozic/ALPushNotificationService.h>
#import <Applozic/ALUtilityClass.h>
#import "ChatOptionVC.h"
#import "Applozic/ALDBHandler.h"
#import "Applozic/ALMessagesViewController.h"
#import "Applozic/ALPushAssist.h"
#import "Applozic/ALMessageService.h"
#import <UserNotifications/UserNotifications.h>


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface AppDelegate () <UNUserNotificationCenterDelegate>


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self registerForNotification];
    // checks wheather app version is updated/changed then makes server call setting VERSION_CODE
    [ALRegisterUserClientService isAppUpdated];
    
    ALAppLocalNotifications *localNotification = [ALAppLocalNotifications appLocalNotificationHandler];
    [localNotification dataConnectionNotificationHandler];
    
    if ([ALUserDefaultsHandler isLoggedIn])
    {
        [ALPushNotificationService userSync];
        
        // Get login screen from storyboard and present it
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ChatOptionVC *viewController = (ChatOptionVC *)[storyboard instantiateViewControllerWithIdentifier:@"ChatOptionVC"];
        
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:viewController
                                                     animated:nil
                                                   completion:nil];
    }
    
    NSLog(@"launchOptions: %@", launchOptions);
    
    if (launchOptions != nil)
    {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"Launched from push notification: %@", dictionary);
            ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
            BOOL applozicProcessed = [pushNotificationService processPushNotification:dictionary
                                                                             updateUI:[NSNumber numberWithInt:APP_STATE_INACTIVE]];
            
            if (!applozicProcessed) {
                //Note: notification for app
            }
        }
    }
    
    return YES;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)dictionary {
    
    NSLog(@"RECEIVED_NOTIFICATION :: %@", dictionary);
    ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
    //    [pushNotificationService processPushNotification:dictionary updateUI:[NSNumber numberWithInt:APP_STATE_INACTIVE]];
    [pushNotificationService notificationArrivedToApplication:application withDictionary:dictionary];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"RECEIVED_NOTIFICATION_WITH_COMPLETION :: %@", userInfo);
    ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
    //    [pushNotificationService processPushNotification:userInfo updateUI:[NSNumber numberWithInt:APP_STATE_BACKGROUND]];
    [pushNotificationService notificationArrivedToApplication:application withDictionary:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"APP_ENTER_IN_BACKGROUND");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTER_IN_BACKGROUND" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [ALPushNotificationService applicationEntersForeground];
    
    NSLog(@"APP_ENTER_IN_FOREGROUND");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTER_IN_FOREGROUND" object:nil];
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[ALDBHandler sharedInstance] saveContext];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"DEVICE_TOKEN :: %@", deviceToken);
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSString *apnDeviceToken = hexToken;
    NSLog(@"APN_DEVICE_TOKEN :: %@", hexToken);
    
    if ([[ALUserDefaultsHandler getApnDeviceToken] isEqualToString:apnDeviceToken])
    {
        return;
    }
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService updateApnDeviceTokenWithCompletion:apnDeviceToken withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        
        if (error)
        {
            NSLog(@"REGISTRATION ERROR :: %@",error.description);
            return;
        }
        
        NSLog(@"Registration response from server : %@", rResponse);
    }];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

-(void)registerForNotification
{
    if(SYSTEM_VERSION_LESS_THAN(@"10.0"))
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if(!error)
             {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                 NSLog(@"Push registration success." );
             }
             else
             {
                 NSLog(@"Push registration FAILED" );
                 NSLog(@"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog(@"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }
}

@end
