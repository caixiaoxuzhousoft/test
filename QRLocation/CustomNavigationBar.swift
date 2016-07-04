//
//  CustomNavigationBar.swift
//  QRLocation
//
//  Created by 根岸 裕太 on 2015/11/13.
//  Copyright © 2015年 根岸 裕太. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    
    override func layoutSubviews() {
        for button in self.subviews {
            if(button.isKindOfClass(UIButton)) {
                button.frame = CGRectMake(8,
                    self.frame.size.height / 2 - button.frame.size.height / 2,
                    button.frame.size.width,
                    button.frame.size.height)
            }
        }
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        
        var barSize = super.sizeThatFits(size)
        
        // navigationHeight
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        barSize.height = screenHeight / 7
        
        // titlePosition
        self.setTitleVerticalPositionAdjustment(-1 * (barSize.height / 5), forBarMetrics: UIBarMetrics.Default)
        
        return barSize
        
    }

}
