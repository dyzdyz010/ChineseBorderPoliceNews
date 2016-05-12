//
//  Page+DomOps.swift
//  BorderPoliceNews
//
//  Created by Du Yizhuo on 16/5/10.
//  Copyright © 2016年 MLTT. All rights reserved.
//

import Foundation
import Kanna

extension Page {
    func parseEntries(doc: HTMLDocument) {
        
        var index = 1
        for area in doc.xpath("//map//area") {
            let entry = Entry()
            entry.points.removeAll()
            
            let coordsStr = area["coords"]!
            let tmpCoordArr = coordsStr.characters.split(",").map(String.init)
            
            var j = 0
            while j < tmpCoordArr.count {
                let p = CGPoint(x: Int(tmpCoordArr[j])!, y: Int(tmpCoordArr[j+1])!)
                entry.points.append(p)
                j += 2
            }
            
            
            let title = area["tooltip"]!
            let href = area["href"]!
            let link = self.baseUrl + "/Html" + href.substringFromIndex(href.startIndex.advancedBy(3))
            
            entry.title = title
            entry.link = link
            entry.index = index
            index += 1
            
            self.entries.append(entry)
        }
    }
}