//
//  AppLogicLoginViewController.swift
//  applozicswift
//
//  Created by Devashish on 30/12/15.
//  Copyright © 2015 Applozic. All rights reserved.
//

import UIKit
import Applozic

class AppLogicLoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var emailId: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ALUserDefaultsHandler.setUserAuthenticationTypeId(1) // APPLOZIC
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func getStartedBtn(_ sender: AnyObject) {

        let alUser : ALUser =  ALUser();
        alUser.applicationId = ALChatManager.applicationId
        
        if(ALChatManager.isNilOrEmpty( self.userName.text as NSString?))
        {
            let alert = UIAlertController(title: "Applozic", message: "Please enter userId ", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        alUser.userId = self.userName.text
        ALUserDefaultsHandler.setUserId(alUser.userId)

        print("userName:: " , alUser.userId)
        if(!((emailId.text?.isEmpty)!)){
             alUser.email = emailId.text
             ALUserDefaultsHandler.setEmailId(alUser.email)
        }

        if (!((password.text?.isEmpty)!)){
            alUser.password = password.text
            ALUserDefaultsHandler.setPassword(alUser.password)
        }
        
        let chatManager = ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.connectUserWithCompletion(alUser) { (response, error) in


            if (error == nil)
            {
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LaunchChatFromSimpleViewController") as UIViewController
                self.present(viewController, animated:true, completion: nil)
            }
        }
    }
    
   
    @IBAction func moreButtonAction(_ sender: AnyObject) {
        
        let alUser : ALUser =  ALUser();
        alUser.applicationId = ALChatManager.applicationId
        
        if(ALChatManager.isNilOrEmpty( self.userName.text as NSString?)){
            let alert = UIAlertController(title: "Applozic", message: "Please enter userId ", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        alUser.userId = self.userName.text
        ALUserDefaultsHandler.setUserId(alUser.userId)
        
        print("userName:: " , alUser.userId)
        if(!((emailId.text?.isEmpty)!)){
            
            alUser.email = emailId.text
            ALUserDefaultsHandler.setEmailId(alUser.email)
        }
        if (!((password.text?.isEmpty)!)){
            alUser.password = password.text
            ALUserDefaultsHandler.setPassword(alUser.password)
        }
        
        let chatManager = ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.connectUserWithCompletion(alUser) { (response, error) in
            
            if (error == nil)
            {
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "moreTabBar") as UIViewController
                self.present(viewController, animated:true, completion: nil)
            }
        }
    }
   
}


