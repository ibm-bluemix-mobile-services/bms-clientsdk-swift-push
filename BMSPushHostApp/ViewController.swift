//
//  ViewController.swift
//  BMSPushHostApp
//
//  Created by Anantha Krishnan K G on 16/02/16.
//  Copyright © 2016 IBM Corp. All rights reserved.
//

import UIKit
public var responseText: String?

class ViewController: UIViewController {
    
    @IBOutlet var textField: UITextView!
    @IBOutlet var swictButton: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateMessage"), name: "action", object: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBAction func switchstateChanged(sender: UISwitch) {
        
        if sender.on{
            
            textField.text = "started Registration \n"
            appDelegate.registerForPush()
        }
        else{
            textField.text = "";
            textField.text = "Unregister Push"
            appDelegate.unRegisterPush()
        }
    }
    
    func updateMessage () {
        
        var responseLabelText = self.textField.text
        responseLabelText = "\(responseLabelText) \n Response Text: \(responseText) \n\n"
        //        let resp:Response? = responseText
        //        var responseLabelText = ""
        //
        //        if resp != nil {
        //            let status = resp!.statusCode ?? 0
        //            let headers = resp!.headers ?? [:]
        //            let responseText = resp!.responseText ?? ""
        //
        //            responseLabelText = "Status Code: \(status) \n\n"
        //            responseLabelText += "Headers: \(headers) \n\n"
        //            responseLabelText += "Response Text: \(responseText) \n\n"
        //        }
        
        
        dispatch_async(dispatch_get_main_queue(), {
            self.textField.text = responseLabelText
        })
    }
    
}

