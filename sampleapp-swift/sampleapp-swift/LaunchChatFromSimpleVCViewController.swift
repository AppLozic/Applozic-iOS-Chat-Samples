//
//  LaunchChatFromSimpleVCViewController.swift
//  sampleapp-swift
//
//  Created by Devashish on 09/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

import UIKit
import Applozic


class LaunchChatFromSimpleVCViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func launchList(_ sender: AnyObject) {
        
        let chatManager : ALChatManager = ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.connectUserAndLaunchChat(getUserDetail(), fromController: self, forUser:nil)
    }
    
    @IBAction func launchUserChat(_ sender: AnyObject)
    {
        let chatManager : ALChatManager =  ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.connectUserAndLaunchChat(getUserDetail(), fromController: self, forUser:"applozic")
        //        chatManager.launchChatForGroup(groupId: NSNumber(value:1344640 as Int32), fromController: self)
    }
    
    
    @IBAction func launchSellerChat(_ sender: AnyObject)
    {
        var alconversationProxy : ALConversationProxy =  ALConversationProxy()
        alconversationProxy = self.makeupConversationDetails()
        
        let chatManager : ALChatManager =  ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.createAndLaunchChatWith(conversationProxy: alconversationProxy, from: self)
    }

    func makeupConversationDetails() -> ALConversationProxy
    {
        let alConversationProxy : ALConversationProxy = ALConversationProxy()
        alConversationProxy.topicId = "laptop01"
        alConversationProxy.userId = "adarshk"
        
        let alTopicDetails : ALTopicDetail = ALTopicDetail()
        alTopicDetails.title     = "Mac Book Pro"
        alTopicDetails.subtitle  = "13' Retina"
        alTopicDetails.link      = "https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/macbookpro.jpg"
        alTopicDetails.key1      = "Product ID"
        alTopicDetails.value1    = "mac-pro-r-13"
        alTopicDetails.key2      = "Price"
        alTopicDetails.value2    = "Rs.1,04,999.00"
        
        let jsonData: Data = jsonToNSData(alTopicDetails.dictionary() as AnyObject)!
        
        let resultTopicDetails : NSString = NSString.init(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
        alConversationProxy.topicDetailJson = resultTopicDetails as String
        
        return alConversationProxy
    }
    
    func jsonToNSData(_ json: AnyObject) -> Data?
    {
        do
        {
            return try JSONSerialization.data(withJSONObject: json, options:JSONSerialization.WritingOptions.prettyPrinted)
        }
        catch let Error
        {
            print(Error)
        }
        return nil;
    }
    
    @IBAction func logout(_ sender: AnyObject)
    {
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.logout { (response, error) in
            
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    func getUserDetail() -> ALUser {
        
        // TODO:Write your won code to get userId in case of update or in case of user is not registered....
        
        let user: ALUser = ALUser()
        user.userId = ALUserDefaultsHandler.getUserId();
        user.password = ALUserDefaultsHandler.getPassword()
        user.displayName = ALUserDefaultsHandler.getDisplayName()

        user.applicationId = ALChatManager.applicationId;
        if(!ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getEmailId() as NSString?)){
            user.email = ALUserDefaultsHandler.getEmailId();
        }
        return user;
    }
    
    
    
}
