//
//  Paper.swift
//  FrontierPoliceNews
//
//  Created by Du Yizhuo on 16/1/26.
//  Copyright © 2016年 MLTT. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

func isPaperAvailable(html: String) -> Bool {
    if html.containsString("没有您要的数据") {
        return false
    } else {
        return true
    }
}

class Paper: NSObject {
    static let baseUrl = "http://www.chinagabf.com/xbfjcb"
    var headlines: [Entry] = [Entry]()
    var pages: [Page] = [Page]()
    var date: NSDate = NSDate()
    
    var map: NSURL? = nil
    
    static func fetchPaper(date: NSDate, callback: Paper? ->()) {
        
        checkPaperAvailability(date) { (exists, resultStr) -> Void in
            if !exists {
                callback(nil)
                return
            }
            
            let paper = Paper()
            
            let doc = Kanna.HTML(html: resultStr.dataUsingEncoding(NSUTF8StringEncoding)!, encoding: NSUTF8StringEncoding)!
            
            // Map image
//            let img = doc.at_xpath("//img[@id='gmipam_0_image']")
//            if img != nil {
//                paper.map = NSURL(string: img!["src"]!)
//            }
            for img in doc.xpath("//div[@class='map']//img") {
                let imgSrc = img["src"]!
                let urlStr = self.baseUrl + imgSrc.substringFromIndex(imgSrc.startIndex.advancedBy(5))
//                print(urlStr)
                paper.map = NSURL(string: urlStr)
            }
            
            // Headlines
            for link in doc.xpath("//ul[@class='pl10 pr10']//a") {
                let urlComp = link["href"]!
                let titleStr = link.text!
                let index = Int(titleStr.substringToIndex(titleStr.startIndex.advancedBy(2)))!
                let title = titleStr.substringFromIndex(titleStr.startIndex.advancedBy(3))
                //                print("\(index): \(title)")
                
                let entry = Entry()
                entry.index = index
                entry.title = title
                entry.link = self.baseUrl + "/Html" + urlComp.substringFromIndex(urlComp.startIndex.advancedBy(2))
                //                    print(entry.link)
                paper.headlines.append(entry)
            }
            //                print(paper.headlines.count)
            
            // Pages
            for link in doc.xpath("//div[@id='pageDis']//a") {
                //                    print(link.text!)
                let urlComp = link["href"]!
                let titleStr = link.text!
                let index = Int(titleStr.substringToIndex(titleStr.startIndex.advancedBy(2)))!
                
                let page = Page()
                page.index = index
                page.title = titleStr
                page.link = self.baseUrl + "/Html" + urlComp.substringFromIndex(urlComp.startIndex.advancedBy(2))
                if index == 1 {
                    for e in paper.headlines {
                        page.entries.append(e)
                    }
                }
                paper.pages.append(page)
                //                    print("\(page.link)")
            }
            
            callback(paper)
        }
    }
    
    static func checkPaperAvailability(date: NSDate, callback: (Bool, String) -> Void) -> Request {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.stringFromDate(date)
//        print(dateStr)
        
        let urlStr = "\(baseUrl)/?Date=\(dateStr)"
        let url = NSURL(string: urlStr)!
        
        let encoding = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        let request = Alamofire.request(.GET, url).responseString(encoding: encoding) { res in
            if let resultStr = res.result.value {
                if res.result.error != nil || !isPaperAvailable(resultStr) {
//                    print(res.result.error)
                    callback(false, "")
                } else {
                    callback(true, resultStr)
//                    print(urlStr)
                }
            } else {
                callback(false, "")
            }
        }
        
        return request
    }
}
