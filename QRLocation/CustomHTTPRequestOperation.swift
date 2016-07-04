//
//  CustomHTTPRequestOperation.swift
//  QRLocation
//
//  Created by 根岸 裕太 on 2015/11/06.
//  Copyright © 2015年 根岸 裕太. All rights reserved.
//

import UIKit

class CustomHTTPRequestOperation : NSObject {
    
    func makeRequestOperation(param:Dictionary<String, AnyObject>, timeoutInterval:NSTimeInterval) -> AFHTTPRequestOperation {
        
        let url : NSURL = NSURL(string: STR_REQUEST_URL_AUTH_STAMP)!
        var jsonData : NSData?
        
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(param, options: NSJSONWritingOptions.PrettyPrinted)
        } catch let error as NSError {
            println(error)
        }
        
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadRevalidatingCacheData, timeoutInterval: timeoutInterval)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        
        return AFHTTPRequestOperation(request: request)
        
    }

}
