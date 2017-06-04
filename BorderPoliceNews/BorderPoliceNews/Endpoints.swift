//
//  Endpoints.swift
//  BorderPoliceNews
//
//  Created by 杜艺卓 on 2017/6/4.
//  Copyright © 2017年 杜艺卓. All rights reserved.
//

import Foundation
import Moya

enum Newspaper {
    case paper(date: Date)
    case page(id: Int)
}
