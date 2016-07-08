//
//  EntryViewController.swift
//  FrontierPoliceNews
//
//  Created by Du Yizhuo on 16/2/26.
//  Copyright © 2016年 MLTT. All rights reserved.
//

import UIKit
import YYText
import YYWebImage

class EntryViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: YYLabel!
    @IBOutlet weak var authorLabel: YYLabel!
    @IBOutlet weak var upperSubtitleLabel: UILabel!
    @IBOutlet weak var lowerSubtitleLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentLabel: YYLabel!
    
    @IBOutlet weak var loadingAnimator: UIActivityIndicatorView!
    
    var entry: Entry? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "文章详情"
        
        if entry?.author == "载入中" {
            entry?.reload(){
//                print(self.entry?.subtitles.count)
                self.makeContent()
            }
        } else {
            makeContent()
        }
        
    }
    
    func setTitles() {
        self.titleLabel.text = self.entry?.title
        self.authorLabel.text = self.entry?.author
        
        if entry?.subtitles.count != 0 {
            self.upperSubtitleLabel.text = entry?.subtitles[0]
        }
        if entry?.subtitles.count > 1 {
            self.lowerSubtitleLabel.text = entry?.subtitles[1]
        }
        //        self.upperSubtitleLabel.hidden = true
        
        self.loadingAnimator.hidden = true
    }
    
    func makeContent() {
        setTitles()
        
        if entry!.images.count == 0 {
            self.imageViewHeightConstraint.constant = 0
        }
        //        let imgpath = NSBundle.mainBundle().pathForResource("logo", ofType: "png")
        //        self.imageView.image = UIImage(contentsOfFile: imgpath!)
        if entry!.images.count > 0 {
            self.imageView.yy_setImageWithURL(entry!.images[0], placeholder: nil, options: YYWebImageOptions.ProgressiveBlur) { (img, url, from, stage, err) -> Void in
                if err != nil {
                    print(err)
                }
            }
        }
        
        let font = UIFont(name: "PingFangSC-Light", size: 18)!
        
        let text = NSMutableAttributedString(string: "")
        
        for p in (entry?.text)! {
            let paragraph = NSMutableAttributedString(string: p)
            text.appendAttributedString(paragraph)
        }
        
        text.yy_font = font
        text.yy_firstLineHeadIndent = 38
        text.yy_paragraphSpacing = 10
        self.contentLabel.attributedText = text
    }
    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        UMSocialData.defaultData().extConfig.wechatSessionData.url = self.entry?.link
        UMSocialData.defaultData().extConfig.wechatTimelineData.url = self.entry?.link
        var img = self.imageView.image
        if img == nil {
            img = UIImage(named: "Link")
        }
        
        UMSocialSnsService.presentSnsIconSheetView(self, appKey: "5704bcbc67e58e9b3500150f", shareText: self.titleLabel.text, shareImage: img, shareToSnsNames: [UMShareToWechatSession, UMShareToWechatTimeline], delegate: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
