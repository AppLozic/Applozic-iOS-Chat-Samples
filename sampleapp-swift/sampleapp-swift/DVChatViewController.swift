//
//  DVChatViewController.swift
//  sampleapp-swift
//
//  Created by Divjyot Singh on 15/04/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

import UIKit
import Applozic

class DVChatViewController: UIViewController {
 
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func backAction(_ sender: Any) {
        /************************ THIS ACTION FOR APPLOZIC USAGE ONLY *************************/
        let registerUserClientService = ALRegisterUserClientService()
        registerUserClientService.logout { (response, error) in
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        setTabBarNavigationTitle("Chat")
        
        let frameworkBundle = Bundle(identifier:"com.applozic.framework")
        let storyboard = UIStoryboard(name: "Applozic", bundle: frameworkBundle)
        let chatController = storyboard.instantiateViewController(withIdentifier: "ALViewController")
        showViewControllerInContainerView(chatController)
//        showViewController(chatController, sender: self)
    }
    
    fileprivate func showViewControllerInContainerView(_ viewController: UIViewController){
        
        for vc in self.children{
            
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        self.addChild(viewController)
        viewController.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height);
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
                                                        attribute: NSLayoutConstraint.Attribute.leading,
                                                        relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: containerView,
            attribute: NSLayoutConstraint.Attribute.leading,
            multiplier: 1,
            constant: 0 ) );
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
                                                        attribute: NSLayoutConstraint.Attribute.top,
                                                        relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: containerView,
            attribute: NSLayoutConstraint.Attribute.top,
            multiplier: 1,
            constant: 0 ) );
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
                                                        attribute: NSLayoutConstraint.Attribute.bottom,
                                                        relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: containerView,
            attribute: NSLayoutConstraint.Attribute.bottom,
            multiplier: 1,
            constant: 0 ) );
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
                                                        attribute: NSLayoutConstraint.Attribute.trailing,
                                                        relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: containerView,
            attribute: NSLayoutConstraint.Attribute.trailing,
            multiplier: 1,
            constant: 0 ) );
        
        containerView.setNeedsUpdateConstraints();
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
