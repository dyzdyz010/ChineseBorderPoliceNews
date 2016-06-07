//
//  ClickableAreaButton.swift
//  BorderPoliceNews
//
//  Created by Du Yizhuo on 16/5/16.
//  Copyright © 2016年 MLTT. All rights reserved.
//

import UIKit

class ClickableAreaButton: UIButton {
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return super.hitTest(point, withEvent: event)
    }
}
