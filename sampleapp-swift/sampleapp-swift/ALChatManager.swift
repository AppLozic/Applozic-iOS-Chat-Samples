//
//  ALChatManager.swift
//  applozicswift
//
//  Created by Devashish on 30/12/15.
//  Copyright © 2015 Applozic. All rights reserved.
//

import UIKit
import Applozic

var TYPE_CLIENT : Int16 = 0
var TYPE_APPLOZIC : Int16 = 1
var TYPE_FACEBOOK : Int16 = 2

var APNS_TYPE_DEVELOPMENT : Int16 = 0
var APNS_TYPE_DISTRIBUTION : Int16 = 1

class ALChatManager: NSObject {
    
    static let applicationId = "applozic-sample-app"
    
    init(applicationKey: NSString) {
        
        ALUserDefaultsHandler.setApplicationKey(applicationKey as String)
    }
    
    // ----------------------
    // Call This at time of your app's user authentication OR User registration.
    // This will register your User at applozic server.
    //----------------------
    
     func connectUser(_ alUser: ALUser) {
        
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: getApplicationKey() as String)
        ALDefaultChatViewSettings()
        alUser.applicationId = getApplicationKey() as String
        alUser.appModuleName = ALUserDefaultsHandler.getAppModuleName()
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.initWithCompletion(alUser, withCompletion: { (response, error) in
            
            if (error != nil)
            {
                print("error while registering to applozic");
            }
            else if(!(response?.isRegisteredSuccessfully())!)
            {
                ALUtilityClass.showAlertMessage("Invalid Password", andTitle: "Oops!!!")
            }

        })
    }
    
     func connectUserWithCompletion(_ alUser: ALUser, completion : @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void) {
    
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: getApplicationKey() as String)
        ALDefaultChatViewSettings()
        alUser.applicationId = getApplicationKey() as String
        alUser.appModuleName = ALUserDefaultsHandler.getAppModuleName()
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
    
        registerUserClientService.initWithCompletion(alUser, withCompletion: { (response, error) in
    
            if (error != nil)
            {
                print("Error while registering to applozic");
                let errorPass = NSError(domain:"Error while registering to applozic", code:0, userInfo:nil)
                completion(response , errorPass as NSError?)
            }
            else if(!(response?.isRegisteredSuccessfully())!)
            {
                ALUtilityClass.showAlertMessage("Invalid Password", andTitle: "Oops!!!")
                let errorPass = NSError(domain:"Invalid Password", code:0, userInfo:nil)
                completion(response , errorPass as NSError?)
            }else{
                completion(response , error as NSError?)
            }

        })
    }
    
    // ----------------------  ------------------------------------------------------/
    // convenient method to launch chat-list, after user registration is done on applozic server.
    //
    // This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
    // ----------------------  ------------------------------------------------------/
    
    func launchChat(_ fromViewController:UIViewController){
        self.connectUserAndLaunchChat(nil, fromController: fromViewController, forUser: nil)
    }
    
    // ----------------------  ------------------------------------------------------/
    // convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
    //
    // This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
    // ----------------------  ------------------------------------------------------/
    
    func launchChatForUser(_ forUserId : String ,fromViewController:UIViewController){
        self.connectUserAndLaunchChat(nil, fromController: fromViewController, forUser: forUserId)
    }
    
    // ----------------------  ------------------------------------------------------/
    //      Method to register + lauch chats screen. If user is already registered, directly chats screen will be launched.
    //      If user information is not passed, it will try to get user information from getLoggedinUserInformation.
    //-----------------------  ------------------------------------------------------/
    
    func connectUserAndLaunchChat(_ alUser:ALUser?, fromController:UIViewController,forUser:String?)
    {
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: getApplicationKey() as String)
       
        if(!ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getDeviceKeyString() as NSString?))
        {
            if (ALChatManager.isNilOrEmpty(forUser as NSString?))
            {
                let title  = ALChatManager.isNilOrEmpty(fromController.title as NSString?) ? "< Back" : fromController.title;
                alChatLauncher.launchChatList(title, andViewControllerObject:fromController);
            }
            else
            {
                alChatLauncher.launchIndividualChat(forUser, withGroupId: nil, andViewControllerObject: fromController, andWithText: nil)
            }
            return;
        }
        
        //register user as it is not registered already ...
        var user : ALUser;
        if (alUser == nil) {
            user = ALChatManager.getUserDetail()
        }else {
            user = alUser!;
        }
        ALDefaultChatViewSettings();
        user.applicationId = getApplicationKey() as String
        user.appModuleName = ALUserDefaultsHandler.getAppModuleName()
        
        // register and launch...
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.initWithCompletion(user, withCompletion: { (response, error) in
            if (error != nil) {
                //TODO : show/handle error
                print("error while registering to applozic");
                return;
            } else if(response?.message == "REGISTERD"){
                print("registered!!!")
                //let messageClientService: ALMessageClientService = ALMessageClientService()
                //messageClientService.addWelcomeMessage()
            }
            if (ALChatManager.isNilOrEmpty(forUser as NSString?)){
                let title  = ALChatManager.isNilOrEmpty(fromController.title as NSString?) ?"< Back" : fromController.title;
                alChatLauncher.launchChatList(title, andViewControllerObject:fromController);
            }else {
                alChatLauncher.launchIndividualChat(forUser, withGroupId: nil, andViewControllerObject: fromController, andWithText: nil)
            }
        })
    }
    
    
    func launchChatForGroup(_ groupId:NSNumber, fromController:UIViewController) -> Void {
        
        let alChatLauncher : ALChatLauncher = ALChatLauncher(applicationId : getApplicationKey() as String)
        
        if(!ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getDeviceKeyString() as NSString?)) {
            
            alChatLauncher.launchIndividualChat(nil, withGroupId: groupId, andViewControllerObject: fromController, andWithText: nil)
             return;
        }
        
        let alUser : ALUser = ALChatManager.getUserDetail()
        alUser.applicationId = getApplicationKey() as String
        alUser.appModuleName = ALUserDefaultsHandler.getAppModuleName()
        let alRegisterUser  = ALRegisterUserClientService()
        alRegisterUser.initWithCompletion(alUser, withCompletion: { (rResponse, error) in
            
            print("USER_REGISTRATION_RESPONSE :: \(rResponse)");
            if (error != nil) {
                print("REGISTRATION_ERROR :: \(error?.localizedDescription)")
                ALUtilityClass.showAlertMessage(rResponse?.message, andTitle:"Response: Cant Register User Client")
                return
            }
            if (rResponse?.message.isEqual("PASSWORD_INVALID"))! {
                ALUtilityClass.showAlertMessage("INAVALID PASSWORD", andTitle:"ALERT!!!")
                return
            }

            if (rResponse?.message.isEqual("REGISTERED"))! {
                
            }
            
            alChatLauncher.launchIndividualChat(nil, withGroupId: groupId, andViewControllerObject: fromController, andWithText: nil)
        })
    }
    
    //====================================================================================================================
    // Call This method if you want create a group of two and launch chat
    //====================================================================================================================

    func launchGroupOfTwo(withClientId clientGroupId: String?, withMetaData metadata: NSMutableDictionary, andWithUser userId: String?, andFrom viewController: UIViewController?) {
        let channelService = ALChannelService()


        channelService.getChannelInformation(nil, orClientChannelKey: clientGroupId, withCompletion: { alChannel in
            guard let alChannel = alChannel else {

                channelService.createChannel(clientGroupId, orClientChannelKey: clientGroupId, andMembersList: [userId], andImageLink: nil, channelType: Int16(GROUP_OF_TWO.rawValue), andMetaData: metadata, withCompletion: { alChannelInRespose, error in
                        if let aKey = alChannelInRespose?.key {
                            print(" group of two id \(aKey)")
                        }
                        self.launchChatForGroup((alChannelInRespose?.key)!, fromController: viewController!)

                    })
                return;
            }

            if (alChannel.key != nil) {
                if ((alChannel.metadata != nil) && !alChannel.metadata.isEqual(to: metadata as! [AnyHashable: Any])) {

                    channelService.updateChannelMetaData(alChannel.key, orClientChannelKey: nil, metadata: metadata, withCompletion: { error in

                        self.launchChatForGroup(alChannel.key, fromController: viewController!)

                    })
                } else {
                    self.launchChatForGroup(alChannel.key, fromController: viewController!)
                }
            }

        })

    }

    func createAndLaunchChatWith(conversationProxy: ALConversationProxy, from viewController: UIViewController) {
        let conversationService = ALConversationService()
        conversationService.createConversation(conversationProxy) { (error, response) in
            guard let proxy = response, error == nil else {
                print("Error creating conversation :: \(String(describing: error))")
                return
            }
            let alConversationProxy = makeFinalProxyWithGeneratedProxy(conversationProxy, responseProxy: proxy)
            let alChatLauncher : ALChatLauncher = ALChatLauncher(applicationId : getApplicationKey() as String)
            alChatLauncher.launchIndividualContextChat(alConversationProxy, andViewControllerObject: viewController, userDisplayName: nil, andWithText: nil)
        }
    }

    // ----------------------  ---------------------------------------------------------------------------------------------//
    //     This method can be used to get app logged-in user's information.
    //     if user information is stored in DB or preference, Code to get user's information should go here.
    //     This might be used to get existing user information in case of app update.
    //----------------------   -----------------------------------------------------------------------------------------//
    
    class func getUserDetail() -> ALUser {
        
        // TODO:Write your won code to get userId in case of update or in case of user is not registered....
        
        let user: ALUser = ALUser()
        user.userId = ALUserDefaultsHandler.getUserId()
        user.applicationId = ALChatManager.applicationId
        user.email = ALUserDefaultsHandler.getEmailId()
        user.password = ALUserDefaultsHandler.getPassword()
//        user.displayName = ALUserDefaultsHandler.getDisplayName()
        
        return user;
        
    }
  
    class func isNilOrEmpty(_ string: NSString?) -> Bool {
        
        switch string {
        case .some(let nonNilString): return nonNilString.length == 0
        default:return true
            
        }
    }
    
// ----------------------  ------------------------------------------------------/
// convenient method to directly launch individual context-based user chat screen. UserId parameter define users for which it intented to launch chat screen.
//
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
// ----------------------  ------------------------------------------------------/
    
    func getApplicationBaseUrl() {
        guard let URLDictionary = Bundle.main.infoDictionary?["APPLOZIC_PRODUCTION"] as? [AnyHashable : Any] else {
            return
        }

        if let baseUrl = URLDictionary["AL_KBASE_URL"] as? String {
            ALUserDefaultsHandler.setBASEURL(baseUrl)
        }

        if let mqttUrl = URLDictionary["AL_MQTT_URL"] as? String {
            ALUserDefaultsHandler.setMQTTURL(mqttUrl)
        }

        if let fileUrl = URLDictionary["AL_FILE_URL"] as? String {
            ALUserDefaultsHandler.setFILEURL(fileUrl)
        }

        if let mqttPort = URLDictionary["AL_MQTT_PORT"] as? String {
            ALUserDefaultsHandler.setMQTTPort(mqttPort)
        }
    }
}

 func getApplicationKey() -> NSString {
    
    let appKey = ALUserDefaultsHandler.getApplicationKey() as NSString?
    let applicationKey = (appKey != nil) ? appKey : ALChatManager.applicationId as NSString?
    return applicationKey!;
    
}

//----------------------------------------------------------------------------------------------------
// The below method combines the conversationID got from server's response with the details already set.
//----------------------------------------------------------------------------------------------------

func makeFinalProxyWithGeneratedProxy (_ generatedProxy:ALConversationProxy, responseProxy:ALConversationProxy)->ALConversationProxy{

    let finalProxy : ALConversationProxy = ALConversationProxy()
    finalProxy.userId = generatedProxy.userId;
    finalProxy.topicDetailJson = generatedProxy.topicDetailJson;
    finalProxy.id = responseProxy.id;
    finalProxy.groupId = responseProxy.groupId;
    
    return finalProxy;
}

//--------------------------------------------------------------------------------------------------------------
// This method helps you customise various settings
//--------------------------------------------------------------------------------------------------------------

func ALDefaultChatViewSettings ()
{
    
     //////////////////////////   SET AUTHENTICATION-TYPE-ID FOR INTERNAL USAGE ONLY ////////////////////////
     ALUserDefaultsHandler.setUserAuthenticationTypeId(TYPE_APPLOZIC)
     ////////////////////////// ////////////////////////// ////////////////////////// ///////////////////////

     
     /*********************************************  NAVIGATION SETTINGS  ********************************************/
     
     ALApplozicSettings.setStatusBarBGColor(UIColor(red:66.0/255, green:173.0/255, blue:247.0/255, alpha:1))
     ALApplozicSettings.setStatusBarStyle(.lightContent)
     /* BY DEFAULT Black:UIStatusBarStyleDefault IF REQ. White: UIStatusBarStyleLightContent  */
     /* ADD property in info.plist "View controller-based status bar appearance" type: BOOLEAN value: NO */
     
     ALApplozicSettings.setColorForNavigation(UIColor(red:66.0/255, green:173.0/255, blue:247.0/255, alpha:1))
     ALApplozicSettings.setColorForNavigationItem(UIColor.white)
     ALApplozicSettings.hideRefreshButton(false)
     ALUserDefaultsHandler.setNavigationRightButtonHidden(false)
     ALUserDefaultsHandler.setBottomTabBarHidden(true)
     ALApplozicSettings.setTitleForConversationScreen("Chats")
     ALApplozicSettings.enableRefreshChatButton(inMsgVc: false)               /*  SET VISIBILITY FOR REFRESH BUTTON (COMES FROM TOP IN MSG VC)   */
     ALApplozicSettings.setTitleForBackButtonMsgVC("Back")                /*  SET BACK BUTTON FOR MSG VC  */
     ALApplozicSettings.setTitleForBackButtonChatVC("Back")               /*  SET BACK BUTTON FOR CHAT VC */
     /****************************************************************************************************************/
     
     
     /***************************************  SEND RECEIVE MESSAGES SETTINGS  ***************************************/
     
     ALApplozicSettings.setSendMsgTextColor(UIColor.white)
     ALApplozicSettings.setReceiveMsgTextColor(UIColor.gray)
     ALApplozicSettings.setColorForReceiveMessages(UIColor(red:255/255, green:255/255, blue:255/255, alpha:1))
     ALApplozicSettings.setColorForSendMessages(UIColor (red:66.0/255, green:173.0/255, blue:247.0/255, alpha:1))
     
     //****************** DATE COLOUR : AT THE BOTTOM OF MESSAGE BUBBLE ******************/
    
     ALApplozicSettings.setDateColor(UIColor(red:51.0/255, green:51.0/255, blue:51.0/255, alpha:0.5))
     
     //****************** MESSAGE SEPERATE DATE COLOUR : DATE MESSAGE ******************/
    
     ALApplozicSettings.setMsgDateColor(UIColor.black)
     
     /***************  SEND MESSAGE ABUSE CHECK  ******************/
     
     ALApplozicSettings.setAbuseWarningText("AVOID USE OF ABUSE WORDS")
     ALApplozicSettings.setMessageAbuseMode(true)
     
     //****************** SHOW/HIDE RECEIVER USER PROFILE ******************/
    
     ALApplozicSettings.setReceiverUserProfileOption(false)
     
     /****************************************************************************************************************/
     
     
     /**********************************************  IMAGE SETTINGS  ************************************************/
     
     ALApplozicSettings.setMaxCompressionFactor(0.1)
     ALApplozicSettings.setMaxImageSizeForUploadInMB(3)
     ALApplozicSettings.setMultipleAttachmentMaxLimit(5)
     /****************************************************************************************************************/
     
     
     /**********************************************  GROUP SETTINGS  ************************************************/
     
     ALApplozicSettings.setGroupOption(true)
     ALApplozicSettings.setGroupExitOption(true)
     ALApplozicSettings.setGroupMemberAddOption(true)
     ALApplozicSettings.setGroupMemberRemoveOption(true)
    
     ALApplozicSettings.setGroupInfoDisabled(false)
     ALApplozicSettings.setGroupInfoEditDisabled(false)

    
     /****************************************************************************************************************/
     
     
     /******************************************** NOTIIFCATION SETTINGS  ********************************************/
     
     //ALUserDefaultsHandler.setDeviceApnsType(APNS_TYPE_DEVELOPMENT)
     //For Distribution CERT::
     //ALUserDefaultsHandler.setDeviceApnsType(APNS_TYPE_DISTRIBUTION)
     
     let appName = Bundle.main.infoDictionary!["CFBundleName"]
     ALApplozicSettings.setNotificationTitle((appName as AnyObject).string)
     
     ALApplozicSettings.enableNotification() //0
     //    ALApplozicSettings.disableNotification() //2
     //    ALApplozicSettings.disableNotificationSound() //1                /*  IF NOTIFICATION SOUND NOT NEEDED  */
     //    ALApplozicSettings.enableNotificationSound() //0                   /*  IF NOTIFICATION SOUND NEEDED    */
     /****************************************************************************************************************/
     
     
     /********************************************* CHAT VIEW SETTINGS  **********************************************/
     
     ALApplozicSettings.setVisibilityForNoMoreConversationMsgVC(false)               /*  SET VISIBILITY NO MORE CONVERSATION (COMES FROM TOP IN MSG VC)  */
     ALApplozicSettings.setEmptyConversationText("You have no conversations yet")    /*  SET TEXT FOR EMPTY CONVERSATION    */
     ALApplozicSettings.setVisibilityForOnlineIndicator(true)                        /*  SET VISIBILITY FOR ONLINE INDICATOR */
    
     let sendButtonColor = UIColor(red:66.0/255, green:173.0/255, blue:247.0/255, alpha:1)   /*  SET COLOR FOR SEND BUTTON   */
     ALApplozicSettings.setColorForSendButton(sendButtonColor)
    
     ALApplozicSettings.setColorForTypeMsgBackground(UIColor.clear)             /*  SET COLOR FOR TYPE MESSAGE OUTER VIEW */
     ALApplozicSettings.setMsgTextViewBGColor(UIColor.lightGray)                /*  SET BG COLOR FOR MESSAGE TEXT VIEW */
     ALApplozicSettings.setPlaceHolderColor(UIColor.gray)                       /*  SET COLOR FOR PLACEHOLDER TEXT */
     ALApplozicSettings.setVisibilityNoConversationLabelChatVC(true)            /*  SET NO CONVERSATION LABEL IN CHAT VC    */
     ALApplozicSettings.setBGColorForTypingLabel(UIColor(red:242/255.0, green:242/255.0, blue:242/255.0, alpha:1))   /*  SET COLOR FOR TYPING LABEL  */
     ALApplozicSettings.setTextColorForTypingLabel(UIColor(red:51.0/255, green:51.0/255, blue:51.0/255, alpha:0.5))  /*  SET COLOR FOR TEXT TYPING LABEL  */
     /****************************************************************************************************************/
     
     
     /********************************************** CHAT TYPE SETTINGS  *********************************************/


    ALApplozicSettings.showChannelMembersInfo(inNavigationBar: true)

     ALApplozicSettings.setContextualChat(true)                                 /*  IF CONTEXTUAL NEEDED    */
     /*  Note: Please uncomment below setter to use app_module_name */
     //   ALUserDefaultsHandler.setAppModuleName("<APP_MODULE_NAME>")
     //   ALUserDefaultsHandler.setAppModuleName("SELLER")
     /****************************************************************************************************************/
     
     
     /*********************************************** CONTACT SETTINGS  **********************************************/
     
     ALApplozicSettings.setFilterContactsStatus(true)                           /*  IF NEEDED ALL REGISTERED CONTACTS   */
     ALApplozicSettings.setOnlineContactLimit(0)                                /*  IF NEEDED ONLINE USERS WITH LIMIT   */
     ALApplozicSettings.setSubGroupLaunchFlag(false)                            /*  IF NEEDED SUB GROUP LAUNCH   */
     /****************************************************************************************************************/
     
     
     /***************************************** TOAST + CALL OPTION SETTINGS  ****************************************/
     
     ALApplozicSettings.setColorForToastText(UIColor.black)                     /*  SET COLOR FOR TOAST TEXT    */
     ALApplozicSettings.setColorForToastBackground(UIColor.gray)                /*  SET COLOR FOR TOAST BG      */
     ALApplozicSettings.setCallOption(true)                                     /*  IF CALL OPTION NEEDED   */
     /****************************************************************************************************************/
     
     
     /********************************************* DEMAND/MISC SETTINGS  ********************************************/
     
     ALApplozicSettings.setUnreadCountLabelBGColor(UIColor.purple)
     ALApplozicSettings.setCustomClassName("ALChatManager")                     /*  SET 3rd Party Class Name OR ALChatManager */
     ALUserDefaultsHandler.setFetchConversationPageSize(20)                     /*  SET MESSAGE LIST PAGE SIZE  */ // DEFAULT VALUE 20
     ALUserDefaultsHandler.setUnreadCountType(1)                                /*  SET UNRAED COUNT TYPE   */ // DEFAULT VALUE 0
     ALApplozicSettings.setMaxTextViewLines(4)
     ALUserDefaultsHandler.setDebugLogsRequire(true)                            /*   ENABLE / DISABLE LOGS   */
     ALUserDefaultsHandler.setLoginUserConatactVisibility(false)
     ALApplozicSettings.setUserProfileHidden(false)
     ALApplozicSettings.setFontFace("Helvetica")
     ALApplozicSettings.setChatWallpaperImageName("<WALLPAPER NAME>")
     ALApplozicSettings.showChannelMembersInfo(inNavigationBar: true)
    
     /****************************************************************************************************************/
     
     
     /***************************************** APPLICATION URL CONFIGURATION + ENCRYPTION  ***************************************/
    
     ALUserDefaultsHandler.setEnableEncryption(false)                            /* Note: PLEASE DO YES (IF NEEDED)  */
     /****************************************************************************************************************/
    
     ALUserDefaultsHandler.setGoogleMapAPIKey("AIzaSyBnWMTGs1uTFuf8fqQtsmLk-vsWM7OrIXk")  /*Note: REPLEACE WITH YOUR GOOGLE MAP KEY  */
    
     ALApplozicSettings.setMsgContainerVC("sampleapp_swift.DVChatViewController")  // appname.ClassName i.e. sampleapp_swift.DVChatViewController
    
    /**********************************************************************************************************************/
    
     ALApplozicSettings.setUserDeletedText("User has been deleted")            /*  SET DELETED USER NOTIFICATION TITLE   */
    
    
    /******************************************** CUSTOM TAB BAR ITEM : ICON && TEXT ************************************************/
     ALApplozicSettings.setChatListTabIcon("")
     ALApplozicSettings.setProfileTabIcon("")
    
     ALApplozicSettings.setChatListTabTitle("")
     ALApplozicSettings.setProfileTabTitle("")
    
}


