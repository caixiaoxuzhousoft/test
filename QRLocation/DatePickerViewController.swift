//
//  DatePickerViewController.swift
//  QRLocation
//
//  Created by 根岸 裕太 on 2015/11/04.
//  Copyright © 2015年 根岸 裕太. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    var emergencyViewController : EmergencyViewController?
    var inputCodeViewController : InputCodeViewController?
    
    @IBOutlet var datePicker : UIDatePicker!
    
    /**
    OKボタン押下時処理
    
    - parameter sender: sender
    */
    @IBAction func okButtonTapped(sender:AnyObject) {
        
        let dateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        if(self.emergencyViewController != nil) {
            self.emergencyViewController?.birthdayTextField.text = dateFormatter.stringFromDate(self.datePicker.date)
        } else if(self.inputCodeViewController != nil) {
            self.inputCodeViewController?.birthdayTextField.text = dateFormatter.stringFromDate(self.datePicker.date)
        }
        
        // save to local documents
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(dateFormatter.stringFromDate(self.datePicker.date), forKey: STR_USERDEFAULTS_KEY_BIRTHDAY)
        defaults.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    キャンセルボタン押下時処理
    
    - parameter sender: sender
    */
    @IBAction func cancelButtonTapped(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /**
    viewDidLoad
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
