//
//  Page.swift
//  FrontierPoliceNews
//
//  Created by Du Yizhuo on 16/1/26.
//  Copyright © 2016年 MLTT. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class Page: NSObject {
    var index: Int = 1
    var title: String = ""
    var readCount: Int = 0
    var link: String = ""
    var entries: [Entry] = [Entry]()
    
    func load(callback: Page? -> Void) {
        let url = NSURL(string: self.link)
        let baseUrl = "http://www.chinagabf.com/xbfjcb/Html"
        //        print(url)
        let encoding = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        Alamofire.request(.GET, url!).responseString(encoding: encoding) { (res) -> Void in
            //                print(res.result.value)
            let resultStr = res.result.value!
            if resultStr.containsString("没有您要的数据") {
                //                print("No Paper for this date.")
                callback(nil)
            } else {
                
                let doc = Kanna.HTML(html: resultStr.dataUsingEncoding(NSUTF8StringEncoding)!, encoding: NSUTF8StringEncoding)!
                
                // Entries
                self.entries.removeAll()
                for a in doc.xpath("//ul[@class='pl10 pr10']//a") {
                    let urlComp = a["href"]!
                    let titleStr = a.text!
                    let index = Int(titleStr.substringToIndex(titleStr.startIndex.advancedBy(2)))!
                    let title = titleStr.substringFromIndex(titleStr.startIndex.advancedBy(3))
                    //                    print("\(index): \(title)")
                    
                    let entry = Entry()
                    entry.index = index
                    entry.title = title
                    entry.link = baseUrl + urlComp.substringFromIndex(urlComp.startIndex.advancedBy(2))
                    //                    print(entry.link)
                    self.entries.append(entry)
                }
                //                print(page.entries.count)
                
                callback(self)
            }
        }
    }
    
    func loadEntries(delegate: EntryDelegate) {
        for e in self.entries {
            //            print("Load entry: \(e.title)")
            e.delegate = delegate
            e.reload(){}
        }
    }
}
