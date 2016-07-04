//
//  MenuViewController.swift
//  QRLocation
//
//  Created by 王国新 on 16/6/21.
//  Copyright © 2016年 根岸 裕太. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBAction func enterOldApp(sender: AnyObject) {
        self.performSegueWithIdentifier("FromMenuViewControllerToReadQRCodeViewController", sender: sender)
    }
    
    @IBAction func enterNewApp(sender: AnyObject) {
        self.performSegueWithIdentifier("FromMenuViewControllerToNewReadQRCodeViewController", sender: sender)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.frame = CGRectMake(0,
                                 0,
                                 (self.navigationController?.navigationBar.frame.width)!,
                                 (self.navigationController?.navigationBar.frame.height)!)
        label.text = "メニュー画面"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(21)
        label.textColor = UIColor.whiteColor()
        label.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = label
    }

    
}
