//
//  InputCodeViewController.swift
//  QRLocation
//
//  Created by 根岸 裕太 on 2015/10/20.
//  Copyright © 2015年 根岸 裕太. All rights reserved.
//

import UIKit
import CoreLocation

class InputCodeViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, SecurityGuardAlertViewDelegate {
    
    var locationManager : CLLocationManager?
    var latitudeString : String?
    var longitudeString : String?
    var addressString : String?
    var activeTextField : UITextField?
    var badPermissionFlag : Bool!
    var observing : Bool!
    
    @IBOutlet var headingLabel : UILabel!
    @IBOutlet var codeTextField : UITextField!
    @IBOutlet var birthdayTextField : UITextField!
    @IBOutlet var mainScrollView : UIScrollView!
    
    /**
     送信ボタンタップ時処理

     - parameter sender: sender
     */
    @IBAction func sendCodeButtonTapped(sender:AnyObject) {
        
        self.view.endEditing(true)
        
        // STR_DEFAULT_CODE_HEADで定義されている文字列を取り除き、1文字目を取得する。
        let imputString : String = self.deleteConstantPrefixWithString(self.codeTextField.text!)
        let firstChar: String = (imputString.substringToIndex((imputString.startIndex.advancedBy(1))))
        
        // 入力コードが警備員用の場合は警備員用人数入力ダイアログを表示
        if firstChar == "6" {
            
            // 警備員用入力ダイアログの表示内容を生成
            var showArray : [String] = []
            for i in 0...SECURITY_GUARD_MAX_NUMBER {
                showArray.append(String(i))
            }
            
            let securityGuardAlertView = SecurityGuardAlertView()
            securityGuardAlertView.delegate = self
            securityGuardAlertView.showAlertControllerWithArray(showArray, viewController: self)
        }
        else {
            
            // バリデーションチェック
            let checkCharSet : NSMutableCharacterSet! = NSMutableCharacterSet.init()
            checkCharSet.addCharactersInString("abcdefghijklmnopqrstuvwxyz")
            checkCharSet.addCharactersInString("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            checkCharSet.addCharactersInString("1234567890_")
            let codeTextString = self.codeTextField.text
            println(codeTextString!.stringByTrimmingCharactersInSet(checkCharSet))
            if(self.codeTextField.text == STR_DEFAULT_CODE_HEAD) {
                
                // エラーダイアログ
                let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_ERROR,
                                                                   message: STR_DIALOG_MESSAGE_NO_CODE,
                                                                   preferredStyle: UIAlertControllerStyle.Alert)
                let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                                                                   style: UIAlertActionStyle.Default,
                                                                   handler: { (action : UIAlertAction) -> Void in
                                                                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
                alert.addAction(defaultAction)
                presentViewController(alert, animated: true, completion: nil)
                
            } else if(self.codeTextField.text!.stringByTrimmingCharactersInSet(checkCharSet).characters.count > 0) {
                
                // エラーダイアログ
                let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_ERROR,
                                                                   message: STR_DIALOG_MESSAGE_VALIDATE,
                                                                   preferredStyle: UIAlertControllerStyle.Alert)
                let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                                                                   style: UIAlertActionStyle.Default,
                                                                   handler: { (action : UIAlertAction) -> Void in
                                                                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
                alert.addAction(defaultAction)
                presentViewController(alert, animated: true, completion: nil)
                
            } else if(self.birthdayTextField.text?.characters.count == 0) {
                
                // エラーダイアログ
                let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_ERROR,
                                                                   message: STR_DIALOG_MESSAGE_NO_BIRTHDAY,
                                                                   preferredStyle: UIAlertControllerStyle.Alert)
                let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                                                                   style: UIAlertActionStyle.Default,
                                                                   handler: { (action : UIAlertAction) -> Void in
                                                                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
                alert.addAction(defaultAction)
                presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                SVProgressHUD.showWithStatus("Sending...")
                
                let reachability = Reachability.reachabilityForInternetConnection()
                let status = reachability.currentReachabilityStatus()
                if (status != NotReachable) {// 接続状態◯
                    
                    // API投げて、成功したら遷移
                    // 遷移先はQR読み取りか、お手伝いさんなら作業者登録画面
                    let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
                    
                    manager.requestSerializer = CustomJSONRequestSerializer()
                    manager.responseSerializer = AFJSONResponseSerializer()
                    
                    // STR_DEFAULT_CODE_HEADで定義されている文字列を取り除く
                    let imputString : String = self.deleteConstantPrefixWithString(self.codeTextField.text!)
                    println(imputString)
                    
                    var birthdayString = self.birthdayTextField.text
                    birthdayString = birthdayString?.stringByReplacingOccurrencesOfString("/", withString: "")
                    
                    // param
                    let version: String! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
                    let param : Dictionary<String, String> = ["app_ver" : version!,
                                                              "type" : "0",
                                                              "code" : imputString,
                                                              "birthday" : birthdayString!,
                                                              "latitude" : self.latitudeString!,
                                                              "longitude" : self.longitudeString!,
                                                              "location" : self.addressString!]
                    
                    if(self.latitudeString == "" && self.longitudeString == "" && self.addressString == "") {
                        
                        let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_CHECK,
                                                                           message: STR_DIALOG_MESSAGE_NO_GPS_DATA,
                                                                           preferredStyle: UIAlertControllerStyle.Alert)
                        let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                                                                           style: UIAlertActionStyle.Default,
                                                                           handler: { (action : UIAlertAction) -> Void in
                                                                            alert.dismissViewControllerAnimated(true, completion: nil)
                                                                            self.sendParameters(param, manager: manager)
                        })
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                        
                        self.sendParameters(param, manager: manager)
                        
                    }
                    
                } else {
                    
                    SVProgressHUD.dismiss()
                    
                    // エラーダイアログ
                    let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_ERROR,
                                                                       message: STR_DIALOG_MESSAGE_NO_NETWORK,
                                                                       preferredStyle: UIAlertControllerStyle.Alert)
                    let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                                                                       style: UIAlertActionStyle.Default,
                                                                       handler: { (action : UIAlertAction) -> Void in
                                                                        alert.dismissViewControllerAnimated(true, completion: nil)
                    })
                    alert.addAction(defaultAction)
                    presentViewController(alert, animated: true, completion: nil)
                    
                }
                
            }
        }
    }
    
    /**
     戻るボタン押下時処理
     */
    func backButtonTapped() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    /**
     initialize

     - parameter aDecoder: coder

     - returns: value
     */
    required init(coder aDecoder: NSCoder) {
        self.latitudeString = ""
        self.longitudeString = ""
        self.addressString = ""
        self.badPermissionFlag = false
        self.observing = false
        super.init(coder: aDecoder)!
    }
    
    /**
     viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.codeTextField.delegate = self
        self.birthdayTextField.delegate = self
        
        // GPSの利用可否判断
        if (CLLocationManager.locationServicesEnabled()) {
            
            self.badPermissionFlag = false
            
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            
            // 100m移動するごとに位置情報を取得
            self.locationManager?.distanceFilter = 100.0
            
            // GPSを取得する旨の認証をリクエストする
            self.locationManager?.requestAlwaysAuthorization()
            
            self.locationManager?.startUpdatingLocation()
            
        } else {
            
            self.badPermissionFlag = true
            
            // GPSの設定画面に飛ばす
            let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_CHECK,
                message: STR_DIALOG_MESSAGE_NO_GPS,
                preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                style: UIAlertActionStyle.Default,
                handler: { (action : UIAlertAction) -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    let url = NSURL(string:"prefs:root=LOCATION_SERVICES")
                    UIApplication.sharedApplication().openURL(url!)
            })
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        
        let backButton = UIBarButtonItem(title: "戻る", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backButtonTapped))
        backButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(backButton, animated: true)
        
        self.headingLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    /**
     viewWillAppear

     - parameter animated: animated
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let label = UILabel()
        label.frame = CGRectMake(0,
            0,
            (self.navigationController?.navigationBar.frame.width)!,
            (self.navigationController?.navigationBar.frame.height)!)
        label.text = "コード入力画面"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(21)
        label.textColor = UIColor.whiteColor()
        label.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = label
        
        // 誕生日持ってたら入れる
        if(NSUserDefaults.standardUserDefaults().objectForKey(STR_USERDEFAULTS_KEY_BIRTHDAY) != nil) {
            let birthday : AnyObject! = NSUserDefaults.standardUserDefaults().objectForKey(STR_USERDEFAULTS_KEY_BIRTHDAY)
            self.birthdayTextField.text = birthday as? String
        }
        
        if(self.observing == false) {
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InputCodeViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InputCodeViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InputCodeViewController.enterForeground(_:)), name:"applicationWillEnterForeground", object: nil)
            
            self.observing = true
            
        }
        
        if(self.locationManager != nil) {
            self.locationManager?.startUpdatingLocation()
        }
        
    }
    
    /**
     viewWillDisappear

     - parameter animated: animated
     */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.observing == true) {
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "applicationWillEnterForeground", object: nil)
            
            self.observing = false
            
        }
        
    }
    
    /**
     prepareForSegue

     - parameter segue:  segue
     - parameter sender: sender
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if(segue.identifier == "FromInputCodeViewControllerToDatePickerViewControllerModal") {
            
            let datePickerViewController : DatePickerViewController = segue.destinationViewController as! DatePickerViewController
            datePickerViewController.inputCodeViewController = self
            
        } else if(segue.identifier == "FromInputCodeViewControllerToEmergencyViewControllerModal") {
            
            let emergencyNavigationViewController : UINavigationController = segue.destinationViewController as! UINavigationController
            let emergencyViewController : EmergencyViewController = emergencyNavigationViewController.viewControllers.first as! EmergencyViewController
            
            // STR_DEFAULT_CODE_HEADで定義されている文字列を取り除く
            let imputString : String = self.deleteConstantPrefixWithString(self.codeTextField.text!)
            emergencyViewController.codeString = imputString
            
        }
        
    }
    
    /**
     enterForegroundNotification

     - parameter notification: notification
     */
    func enterForeground(notification: NSNotification){
        
        if(self.badPermissionFlag == false) {
            return
        }
        
        // GPSの利用可否判断
        if (CLLocationManager.locationServicesEnabled()) {
            
            self.badPermissionFlag = false
            
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            
            // 100m移動するごとに位置情報を取得
            self.locationManager?.distanceFilter = 100.0
            
            // GPSを取得する旨の認証をリクエストする
            self.locationManager?.requestAlwaysAuthorization()
            
            self.locationManager?.startUpdatingLocation()
            
        } else {
            
            self.badPermissionFlag = true
            
            // GPSの設定画面に飛ばす
            let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_CHECK,
                message: STR_DIALOG_MESSAGE_NO_GPS,
                preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                style: UIAlertActionStyle.Default,
                handler: { (action : UIAlertAction) -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    let url = NSURL(string:"prefs:root=LOCATION_SERVICES")
                    UIApplication.sharedApplication().openURL(url!)
            })
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    /**
     UITextFieldDelegate
    textfieldの編集が始まる時に呼ばれる

     - parameter textField: textfield

     - returns: 編集させるかbool
     */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.activeTextField = textField
        
        if(textField == self.birthdayTextField) {
            
            self.performSegueWithIdentifier("FromInputCodeViewControllerToDatePickerViewControllerModal", sender: self)
            
            return false
        }
        
        return true
    }
    
    /**
     UITextFieldDelegate
    textfieldが編集されるたびに呼ばれる

     - parameter textField: textfield
     - parameter range:     range
     - parameter string:    入力された文字

     - returns: 編集させるかbool
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // カーソルが6文字以内の時は編集させない
        if(range.location < 6) {
            return false
        }
        
        if(string == "") {
            return true
        }
        
        let afterText : String = String(textField.text! + string)
        
        let attributedString = NSMutableAttributedString.init(string: afterText)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, 6))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSMakeRange(6, afterText.characters.count - 6))
        
        textField.attributedText = attributedString
        
        return false
    }
    
    /**
     UITextFieldDelegate
    キーボードのreturnが押された時に呼ばれる

     - parameter textField: textfield

     - returns: bool
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    /**
     keyboardNotification
    キーボードが表示された時

     - parameter notification: notification
     */
    func keyboardWillShow(notification:NSNotification) {
        
        let userInfo = notification.userInfo
        let keyboardScreenEndFrame = (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        
        // textfieldの下辺とkeyboardの上辺
        let textFieldUnderLimit = self.activeTextField!.frame.origin.y + self.activeTextField!.frame.height + 8.0
        
        if(textFieldUnderLimit >= keyboardScreenEndFrame!.size.height) {
            
            self.mainScrollView.contentOffset.y = textFieldUnderLimit - keyboardScreenEndFrame!.size.height
            
        }
        
    }
    
    /**
     keyboardNotification
    キーボードが隠れた時

     - parameter notification: notification
     */
    func keyboardWillHide(notification:NSNotification) {
        
        self.mainScrollView.contentOffset.y = 0
        
    }
    
    /**
     locationDelegate
    現在位置が更新されるたびに呼ばれる

     - parameter manager:     manager
     - parameter newLocation: newlocation
     - parameter oldLocation: oldlocation
     */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        // 緯度
        let latitudeString = String(newLocation.coordinate.latitude)
        // 経度
        let longitudeString = String(newLocation.coordinate.longitude)
        
        self.latitudeString = latitudeString
        self.longitudeString = longitudeString
        
        // リバースジオコーディング
        let location = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks: Array?, error: NSError?) -> Void in
            
            if (error == nil && placemarks!.count > 0) {
                let placemark = placemarks![0] as CLPlacemark
                
                var administrativeArea = placemark.administrativeArea
                var locality = placemark.locality
                var thoroughfare = placemark.thoroughfare
                var subThoroughfare = placemark.subAdministrativeArea
                
                if(administrativeArea == nil) {
                    administrativeArea = ""
                }
                if(locality == nil) {
                    locality = ""
                }
                if(thoroughfare == nil) {
                    thoroughfare = ""
                }
                if(subThoroughfare == nil) {
                    subThoroughfare = ""
                }
                
                self.addressString = administrativeArea! + locality! + thoroughfare! + subThoroughfare!
                
            } else {
                
                // 位置情報エラーが出た時点で、位置情報を空にする
                self.latitudeString = ""
                self.longitudeString = ""
                self.addressString = ""
                
                println("location error")
            }
            
        })
        
    }
    
    /**
     locationDelegate
    エラーが起きた時に呼ばれる

     - parameter manager: manager
     - parameter error:   error
     */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        // 位置情報エラーが出た時点で、位置情報を空にする
        self.latitudeString = ""
        self.longitudeString = ""
        self.addressString = ""
        
        if(error.code == CLError.Denied.rawValue) {
            
            self.badPermissionFlag = true
            
            if(!CLLocationManager.locationServicesEnabled()) {// 位置情報がOFFになっている場合
                
                // GPSの設定画面に飛ばす
                let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_CHECK,
                    message: STR_DIALOG_MESSAGE_NO_GPS,
                    preferredStyle: UIAlertControllerStyle.Alert)
                let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler: { (action : UIAlertAction) -> Void in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        let url = NSURL(string:"prefs:root=LOCATION_SERVICES")
                        UIApplication.sharedApplication().openURL(url!)
                })
                alert.addAction(defaultAction)
                presentViewController(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func sendParameters(param: Dictionary<String, String>, manager : AFHTTPRequestOperationManager) {
        
        manager.POST(STR_REQUEST_URL_AUTH_STAMP,
            parameters: param,
            success: { (operation:AFHTTPRequestOperation, responseObject:AnyObject) -> Void in
                
                println("success")
                let responseCommon : Dictionary<String, AnyObject>? = responseObject.objectForKey("common") as? Dictionary
                let responseData : Dictionary<String, AnyObject>? = responseObject.objectForKey("data") as? Dictionary
                
                println(responseCommon!);
                
                if(responseCommon != nil && responseCommon?.count > 0) {
                    
                    SVProgressHUD.dismiss()
                    
                    if(responseCommon!["status"] as! Int == 0) {
                        
                        if(responseData!["type"] as! String == "0"){
                            
                            // 成功ダイアログ
                            let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_CHECK,
                                message: STR_DIALOG_MESSAGE_SEND_SUCCESS,
                                preferredStyle: UIAlertControllerStyle.Alert)
                            let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                                style: UIAlertActionStyle.Default,
                                handler: { (action : UIAlertAction) -> Void in
                                    alert.dismissViewControllerAnimated(true, completion: nil)
                                    self.dismissViewControllerAnimated(true, completion: nil)
                            })
                            alert.addAction(defaultAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            // 成功ダイアログ
                            let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_CHECK,
                                message: STR_DIALOG_MESSAGE_SEND_SUCCESS,
                                preferredStyle: UIAlertControllerStyle.Alert)
                            let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                                style: UIAlertActionStyle.Default,
                                handler: { (action : UIAlertAction) -> Void in
                                    alert.dismissViewControllerAnimated(true, completion: nil)
                                    self.performSegueWithIdentifier("FromInputCodeViewControllerToEmergencyViewControllerModal", sender: self)
                            })
                            alert.addAction(defaultAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                            return
                            
                        }
                        
                        
                    } else {
                        
                        // 失敗ダイアログ
                        let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_ERROR,
                            message: responseCommon!["msg"] as? String,
                            preferredStyle: UIAlertControllerStyle.Alert)
                        let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                            style: UIAlertActionStyle.Default,
                            handler: { (action : UIAlertAction) -> Void in
                                alert.dismissViewControllerAnimated(true, completion: nil)
                        })
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                }
                
                
            }, failure: { (operation, error) -> Void in
                println("failure")
                
                SVProgressHUD.dismiss()
                
                var messageString : String = STR_DIALOG_MESSAGE_SEND_FAILURE
                
                if(error.code == -1001) {
                    messageString = STR_DIALOG_MESSAGE_TIMEOUT
                }
                
                // エラーダイアログ
                let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_ERROR,
                    message: messageString,
                    preferredStyle: UIAlertControllerStyle.Alert)
                let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler: { (action : UIAlertAction) -> Void in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                })
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
    /**
     STR_DEFAULT_CODE_HEADで定義されている文字列を除いた文字列を取得する。
     */
    func deleteConstantPrefixWithString(string : String) -> String {
        var inputStr = string
        
        // STR_DEFAULT_CODE_HEADで定義されている文字列を除いた1文字目を取得する。
        let strDefaultCodeHeadCount = STR_DEFAULT_CODE_HEAD.characters.count
        inputStr = (inputStr.substringFromIndex((inputStr.startIndex.advancedBy(strDefaultCodeHeadCount))))
        
        return inputStr
    }
    
    //MARK: - SecurityGuardAlertViewDelegate
    
    func cancelButtonDidTap() {
        
    }
    
    func okButtonDidTap(selectedValue : String) {
        
        let reachability = Reachability.reachabilityForInternetConnection()
        let status = reachability.currentReachabilityStatus()
        if (status != NotReachable) {// 接続状態◯
            
            let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
            
            manager.requestSerializer = CustomJSONRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer()
            
            // param
            let version: String! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
            
            // STR_DEFAULT_CODE_HEADで定義されている文字列を取り除く
            let imputString : String = self.deleteConstantPrefixWithString(self.codeTextField.text!)
            
            let param : Dictionary<String, String> = ["app_ver" : version!,
                                                      "type" : "0",
                                                      "code" : imputString,
                                                      "latitude" : self.latitudeString!,
                                                      "longitude" : self.longitudeString!,
                                                      "location" : self.addressString!,
                                                      "headcount" : selectedValue]
            self.sendParameters(param, manager: manager)
        }
    }
}
