//
//  ReadQRCodeViewController.swift
//  QRLocation
//
//  Created by 根岸 裕太 on 2015/10/20.
//  Copyright © 2015年 根岸 裕太. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ReadQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CLLocationManagerDelegate, SecurityGuardAlertViewDelegate {
    
    var session : AVCaptureSession?
    var locationManager : CLLocationManager?
    var latitudeString : String?
    var longitudeString : String?
    var addressString : String?
    var codeString : String?
    var captureFlag : Bool!
    var badPermissionFlag : Bool!
    var observing : Bool!
    
    @IBOutlet var cameraView : UIView!
    
    /**
    コードを入力ボタン押下時処理
    
    - parameter sender: sender
    */
    @IBAction func inputCodeButtonTapped(sender:AnyObject) {
        
        self.performSegueWithIdentifier("FromReadQRCodeViewControllerToInputCodeViewControllerModal", sender: self)
        
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
        self.codeString = ""
        self.session = AVCaptureSession()
        self.captureFlag = true
        self.badPermissionFlag = false
        self.observing = false
        super.init(coder: aDecoder)!
    }
    
    /**
     viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.settingPermissionsForThisApp()
        
        let backButton = UIBarButtonItem(title: "戻る", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backButtonTapped))
        backButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(backButton, animated: true)

        
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
        label.text = "QRコードを配置してください"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(21)
        label.textColor = UIColor.whiteColor()
        label.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = label
        
        if(self.observing == false) {
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReadQRCodeViewController.enterForeground(_:)), name:"applicationWillEnterForeground", object: nil)
            
            self.observing = true
            
        }
        
        if(self.locationManager != nil) {
            self.locationManager?.startUpdatingLocation()
        }
        
    }
    
    /**
    viewDidAppear
    
    - parameter animated: animated
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.captureFlag = true
        
        if(self.session!.running == false) {
        
            // start
            self.session!.startRunning()
            
            // layerを重ねる
            let preview = AVCaptureVideoPreviewLayer(session: self.session) as AVCaptureVideoPreviewLayer
            preview.frame = self.cameraView.bounds
            preview.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.cameraView.layer.addSublayer(preview)
            
        }
    }
    
    /**
    viewWillDisappear
    
    - parameter animated: animated
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.observing == true) {
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "applicationWillEnterForeground", object: nil)
            
            self.observing = false
            
        }
        
    }
    
    /**
    prepareForSegue
    
    - parameter segue:  segue
    - parameter sender: sender
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "FromReadQRCodeViewControllerToEmergencyViewControllerModal") {
            let navigationController : UINavigationController = segue.destinationViewController as! UINavigationController
            let emergencyViewController : EmergencyViewController = navigationController.viewControllers.first as! EmergencyViewController
            emergencyViewController.codeString = self.codeString
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
        
        self.settingPermissionsForThisApp()
        
    }
    
    /**
     戻るボタン押下時処理
     */
    func backButtonTapped() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    AVCaptureDelegate
    コードがキャプチャされた時に呼ばれる
    
    - parameter captureOutput:   output
    - parameter metadataObjects: metadata
    - parameter connection:      connection
    */
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if(self.captureFlag == false) {
            return
        }
        
        println("----")
        for metadata in metadataObjects {
            metadata as! AVMetadataObject
            if (metadata.type == AVMetadataObjectTypeQRCode) {
                // 複数の QR があっても1度で読み取れている
                self.codeString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
            } else if (metadata.type == AVMetadataObjectTypeEAN13Code) {
                self.codeString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
            }
        }
        
        if(self.codeString == "") {
            self.captureFlag = true
            return
        } else {
            self.captureFlag = false
            println(self.codeString!)
        }
        
        let firstChar: String = (self.codeString!.substringToIndex((self.codeString!.startIndex.advancedBy(1))))
        
        // QRコードの読み取り結果が6から始まる場合は警備員人数入力ダイアログを表示
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
            // 通信テスト
            SVProgressHUD.showWithStatus("Sending...")
            
            let reachability = Reachability.reachabilityForInternetConnection()
            let status = reachability.currentReachabilityStatus()
            if (status != NotReachable) {// 接続状態◯
                
                let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
                
                manager.requestSerializer = CustomJSONRequestSerializer()
                manager.responseSerializer = AFJSONResponseSerializer()
                
                // param
                let version: String! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
                let param : Dictionary<String, String> = ["app_ver" : version!,
                                                          "type" : "0",
                                                          "code" : self.codeString!,
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
                                                                    self.captureFlag = true
                                                                    
                })
                alert.addAction(defaultAction)
                presentViewController(alert, animated: true, completion: nil)
                
                self.codeString = ""
                
            }
        }
    }
    
    /**
    locationDelegate
    現在位置が更新されるたびに呼ばれる
    
    - parameter manager:     manager
    - parameter newLocation: newlocation
    - parameter oldLocation: oldlocation
    */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        println("loc")
        
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
                println("location error")
            }
            
        })
        
    }
    
    /**
     locationDelegate
    エラーが起きた時に呼ばれる

     - parameter manager: manger
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
                
            } else {// 位置情報の許可を「許可しない」にした場合
                
                // アプリの設定画面に飛ばす
                let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_CHECK,
                    message: STR_DIALOG_MESSAGE_NO_GPS,
                    preferredStyle: UIAlertControllerStyle.Alert)
                let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler: { (action : UIAlertAction) -> Void in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                        let url = NSURL(string:UIApplicationOpenSettingsURLString)
                        UIApplication.sharedApplication().openURL(url!)
                })
                alert.addAction(defaultAction)
                presentViewController(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    /**
     このアプリ用にパーミッションのチェック等をする
    カメラとGPS
     */
    func settingPermissionsForThisApp() {
        
        // デバイスのどのキャプチャデバイスを利用するか
        let devices : Array = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var device : AVCaptureDevice? = nil
        let camera : AVCaptureDevicePosition = AVCaptureDevicePosition.Back
        for devicesElement in devices {
            device = devicesElement as? AVCaptureDevice
            if (devicesElement.position == camera) {
                break
            }
        }
        
        // inputを取得してadd
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if(self.session!.canAddInput(input)) {
                self.session!.addInput(input)
            }
        } catch let error as NSError {
            println(error)
            
            self.badPermissionFlag = true
            
            // アプリの設定画面に飛ばす
            let alert : UIAlertController = UIAlertController (title: STR_DIALOG_TITLE_CHECK,
                message: STR_DIALOG_MESSAGE_NO_CAMERA,
                preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction : UIAlertAction = UIAlertAction (title: "OK",
                style: UIAlertActionStyle.Default,
                handler: { (action : UIAlertAction) -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    let url = NSURL(string:UIApplicationOpenSettingsURLString)
                    UIApplication.sharedApplication().openURL(url!)
            })
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // outputを取得してadd
        let output : AVCaptureMetadataOutput = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        if(self.session!.canAddOutput(output)) {
            self.session!.addOutput(output)
        }
        
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // GPSの利用可否判断
        if (CLLocationManager.locationServicesEnabled()) {
            
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            
            // 100m移動するごとに位置情報を取得
            self.locationManager?.distanceFilter = 100.0
            
            // GPSを取得する旨の認証をリクエストする
            self.locationManager?.requestAlwaysAuthorization()
            
            self.locationManager?.startUpdatingLocation()
            
        } else {// GPSがOFF
            
            self.badPermissionFlag = true
            
        }
        
    }
    
    func sendParameters(param: Dictionary<String, String>, manager: AFHTTPRequestOperationManager) {
        
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
                                    self.captureFlag = true
                            })
                            alert.addAction(defaultAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                            self.codeString = ""
                            
                        } else {
                            
                            self.performSegueWithIdentifier("FromReadQRCodeViewControllerToEmergencyViewControllerModal", sender: self)
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
                                self.captureFlag = true
                        })
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        self.codeString = ""
                        
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
                        self.captureFlag = true
                })
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
                
                self.codeString = ""
                
        })
    }
    
    //MARK: - SecurityGuardAlertViewDelegate
    func cancelButtonDidTap() {
        self.captureFlag = true
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
            let param : Dictionary<String, String> = ["app_ver" : version!,
                                                      "type" : "0",
                                                      "code" : self.codeString!,
                                                      "latitude" : self.latitudeString!,
                                                      "longitude" : self.longitudeString!,
                                                      "location" : self.addressString!,
                                                      "headcount" : selectedValue]
            self.sendParameters(param, manager: manager)
        }
    }
}

