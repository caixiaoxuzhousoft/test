//
//  NewDatePickerViewController.swift
//  QRLocation
//
//  Created by 王国新 on 16/6/22.
//  Copyright © 2016年 根岸 裕太. All rights reserved.
//

import UIKit

class NewDatePickerViewController: UIViewController {

    var newInputCodeViewController : NewInputCodeViewController?

    @IBOutlet var datePicker : UIDatePicker!
    
    /**
     OKボタン押下時処理
     
     - parameter sender: sender
     */
    @IBAction func okButtonTapped(sender:AnyObject) {
        
        let dateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        if(self.newInputCodeViewController != nil) {
            self.newInputCodeViewController?.birthdayTextField.text = dateFormatter.stringFromDate(self.datePicker.date)
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(dateFormatter.stringFromDate(self.datePicker.date), forKey: STR_USERDEFAULTS_KEY_BIRTHDAY)
        defaults.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
