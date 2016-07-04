//
//  SecurityGuardAlertView.swift
//  QRLocation
//
//  Created by 千葉 照純 on 2016/05/17.
//  Copyright © 2016年 根岸 裕太. All rights reserved.
//

import UIKit
import Foundation

@objc protocol SecurityGuardAlertViewDelegate {
    // キャンセルボタンタップ時
    func cancelButtonDidTap()
    
    // okボタンタップ時
    func okButtonDidTap(selectedValue : String)
}

class SecurityGuardAlertView: UIViewController, UIPickerViewDelegate {
    
    weak var delegate: SecurityGuardAlertViewDelegate?
    var pickerStringArray : [String] = []
    var pickerView : UIPickerView = UIPickerView()
    var textField : UITextField?
    var toolBar : UIToolbar!

    /**
     警備員用人数入力ダイアログを表示する。
     */
    func showAlertControllerWithArray(array :NSArray, viewController : UIViewController) {
        
        self.pickerStringArray = array as! [String]
        
        // AlertController作成
        let alert : UIAlertController = UIAlertController(title:STR_DIALOG_TITLE_NUMBER,
                                                          message: "",
                                                          preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel",
                                                         style: UIAlertActionStyle.Cancel,
                                                         handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            self.delegate?.cancelButtonDidTap()
        })
        let defaultAction : UIAlertAction = UIAlertAction(title: "OK",
                                                          style: UIAlertActionStyle.Default,
                                                          handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            self.delegate?.okButtonDidTap(self.textField!.text!)
                                                            
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // textField追加
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
            self.textField = text
            self.textField!.textAlignment = NSTextAlignment.Right
            self.textField!.text = self.pickerStringArray[0]
            
            self.pickerView.showsSelectionIndicator = true
            self.pickerView.delegate = self
            self.pickerView.selectRow(0, inComponent: 0, animated: false)
            self.textField!.inputView = self.pickerView
            
            self.toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
            self.toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
            self.toolBar.barStyle = .Default
            self.toolBar.tintColor = UIColor.blackColor()
            self.toolBar.backgroundColor = UIColor.whiteColor()
            let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,target: nil,action: nil)
            let barButtonItem : UIBarButtonItem = UIBarButtonItem(title: STR_TOOLBAR_BUTTON_TITLE, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.tappedToolBarBtn))
            self.toolBar.items = [spaceBarBtn, barButtonItem]
            self.textField!.inputAccessoryView = self.toolBar
        })
        
        viewController.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - UIPickerViewDelegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerStringArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerStringArray[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textField!.text = pickerStringArray[row]
    }
    
    //MARK: - ToolBerButton Event
    
    func tappedToolBarBtn(sender: UIBarButtonItem){
        self.textField!.resignFirstResponder()
    }

}
