//
//  CustomJSONRequestSerializer.swift
//  QRLocation
//
//  Created by 根岸 裕太 on 2015/10/22.
//  Copyright © 2015年 根岸 裕太. All rights reserved.
//

import UIKit

class CustomJSONRequestSerializer: AFJSONRequestSerializer {
    
    override func requestWithMethod(method: String, URLString: String, parameters: AnyObject?, error: NSErrorPointer) -> NSMutableURLRequest {
               
        let request : NSMutableURLRequest = super.requestWithMethod(method, URLString: URLString, parameters: parameters, error: error)
        
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.HTTPShouldHandleCookies = false
        request.timeoutInterval = TIME_OUT
        
        return request
        
    }

}
