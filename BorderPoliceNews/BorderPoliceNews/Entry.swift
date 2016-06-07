//
//  Entry.swift
//  FrontierPoliceNews
//
//  Created by Du Yizhuo on 16/1/26.
//  Copyright © 2016年 MLTT. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

protocol EntryDelegate {
    func entryDidFinishLoading(entry: Entry)
}

class Entry: NSObject {
    var index: Int = 1
    var title: String = ""
    var subtitles: [String] = []
    var author: String = "载入中"
    var viewCount: String = "0"
    var readCount: Int = 0
    var text: [String] = []
    var images: [NSURL?] = [NSURL?]()
    var link: String = ""
    var points: [CGPoint] = [CGPoint]()
    
    var delegate: EntryDelegate? = nil
    
    static func entryWithUrl(url: NSURL?, _ closure: Page? ->()) {
        
    }
    
    func reload(completionHandler: () -> Void) {
        print(self.link)
        
        let encoding = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        
        Alamofire.request(.GET, self.link).responseString(encoding: encoding) { (res) -> Void in
            //            print("Data: \(NSString(data: res.data!, encoding: encoding))")
            if res.result.error != nil {
                print(res.result.error)
                return
            }
            let resultStr = res.result.value!
            let doc = Kanna.HTML(html: resultStr.dataUsingEncoding(NSUTF8StringEncoding)!, encoding: NSUTF8StringEncoding)!
            
            // Get title
            if let h1 = doc.at_xpath("//div[@class='newsdetail_bg clearfix']//h1") {
                //                print(h1.text)
                self.title = h1.text!
            }
            
            // Get authors and view count
            if let author = doc.at_xpath("//div[@class='newsdetail_bg clearfix']//div[@align='center']") {
                let divider = "查看次数："
                let line = author.text!
                let authorComponent = line.substringToIndex((line.rangeOfString(divider)?.startIndex)!)
                let viewsComponent = line.substringFromIndex((line.rangeOfString(divider)?.endIndex)!)
                
                let author = authorComponent.substringFromIndex((authorComponent.rangeOfString("新闻作者：")?.endIndex)!)
                let viewCount = viewsComponent.substringToIndex((viewsComponent.rangeOfString("次")?.startIndex)!)
                
                self.author = author
                self.viewCount = viewCount
            }
            
            // Get subtitles
            for h2 in doc.xpath("//div[@class='newsdetail_bg clearfix']//h2") {
                let st = h2.text!
                self.subtitles.append(st)
            }
            
            
            // Get paragraphs
            for p in doc.xpath("//div[@id='content']//p") {
                let t = p.text!
                if t != "" {
                    self.text.append(t.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) + "\n")
                }
            }
            
            // Get image
            if let img = doc.at_xpath("//div[@id='content']//img") {
                let relPath = img["src"]!
                let urlStr = "http://www.chinagabf.com/xbfjcb" + relPath.substringFromIndex(relPath.characters.startIndex.advancedBy(5))
                
                let url = NSURL(string: urlStr)!
                //                print(url)
                
                self.images.append(url)
            }
            
            completionHandler()
            self.delegate?.entryDidFinishLoading(self)
        }
        
    }
}
