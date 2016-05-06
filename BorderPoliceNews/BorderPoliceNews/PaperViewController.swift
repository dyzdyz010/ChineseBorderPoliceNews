//
//  PaperViewController.swift
//  BorderPoliceNews
//
//  Created by Du Yizhuo on 16/4/18.
//  Copyright © 2016年 MLTT. All rights reserved.
//

import SwiftDate

class PaperViewController: UIViewController, UIScrollViewDelegate, EntryDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var thumbImageViewArr: [UIImageView] = [UIImageView]()
    
    var date: NSDate = NSDate()
    var paper: Paper? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPaper()
    }
    
    func loadPaper() {
        Paper.fetchPaper(self.date) { (paper) -> () in
            if paper == nil {
                self.date = self.date - 1.days
                self.loadPaper()
                return
            }
            
            self.paper = paper
            self.setupPageScroll()
            self.loadPage()
        }
    }
    
    func loadPage() {
        let pageCount = self.paper!.pages.count
        for i in 1...pageCount {
            self.paper?.pages[i-1].load({ page in
                self.flushThumb(index: i-1, page: page!)
                page?.loadEntries(self)
            })
        }
    }
    
    func setupPageScroll() {
        let pageCount = (self.paper?.pages.count)!
        self.thumbImageViewArr = [UIImageView](count: pageCount, repeatedValue: UIImageView())
        
        let tabbarHeight = self.tabBarController!.tabBar.frame.size.height
        let navibarHeight = self.navigationController!.navigationBar.frame.size.height
        scrollView.frame = CGRect(x: 0, y: navibarHeight, width: self.view.frame.width, height: self.view.frame.height - tabbarHeight - navibarHeight)
        let scrollWidth = scrollView.frame.width
        let scrollHeight = scrollView.frame.height
        
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollWidth, height: scrollHeight))
        imgView.yy_imageURL = NSURL(string: paper!.thumbUrl)
        imgView.contentMode = .ScaleAspectFit
        scrollView.addSubview(imgView)
        self.thumbImageViewArr.append(imgView)
        
//        for i in 1...pageCount {
//            let imgView = UIImageView(frame: CGRect(x: CGFloat(i-1) * scrollWidth, y: 0, width: scrollWidth, height: scrollHeight))
//            if i == 1 {
//                imgView.yy_imageURL = NSURL(string: paper!.thumbUrl)
//            } else {
//                imgView.yy_imageURL = NSURL(string: paper!.pages[i-1].thumbUrl)
//            }
//            imgView.contentMode = .ScaleAspectFit
//            scrollView.addSubview(imgView)
//            self.thumbImageViewArr.append(imgView)
//        }
        
//        let imgView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollWidth, height: scrollHeight))
//        imgView1.image = UIImage(named: "img1")
//        imgView1.contentMode = .ScaleAspectFit
//        
//        let imgView2 = UIImageView(frame: CGRect(x: scrollWidth, y: 0, width: scrollWidth, height: scrollHeight))
//        imgView2.image = UIImage(named: "img2")
//        imgView2.contentMode = .ScaleAspectFit
//        
//        let imgView3 = UIImageView(frame: CGRect(x: 2*scrollWidth, y: 0, width: scrollWidth, height: scrollHeight))
//        imgView3.image = UIImage(named: "img3")
//        imgView3.contentMode = .ScaleAspectFit
//        
//        let imgView4 = UIImageView(frame: CGRect(x: 3*scrollWidth, y: 0, width: scrollWidth, height: scrollHeight))
//        imgView4.image = UIImage(named: "img4")
//        imgView4.contentMode = .ScaleAspectFit
//        
//        scrollView.addSubview(imgView1)
//        scrollView.addSubview(imgView2)
//        scrollView.addSubview(imgView3)
//        scrollView.addSubview(imgView4)
        scrollView.contentSize = CGSize(width: CGFloat(pageCount)*scrollWidth, height: scrollHeight)
        scrollView.delegate = self
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
    }
    
    func flushThumb(index index: Int, page: Page) {
        if index == 0 {
            return
        }
        
        let tabbarHeight = self.tabBarController!.tabBar.frame.size.height
        let navibarHeight = self.navigationController!.navigationBar.frame.size.height
        scrollView.frame = CGRect(x: 0, y: navibarHeight, width: self.view.frame.width, height: self.view.frame.height - tabbarHeight - navibarHeight)
        let scrollWidth = scrollView.frame.width
        let scrollHeight = scrollView.frame.height
        
        let imgView = UIImageView(frame: CGRect(x: CGFloat(index)*scrollWidth, y: 0, width: scrollWidth, height: scrollHeight))
        imgView.yy_imageURL = NSURL(string: page.thumbUrl)
        imgView.contentMode = .ScaleAspectFit
        scrollView.addSubview(imgView)
        self.thumbImageViewArr.append(imgView)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = self.scrollView.frame.size.width
        let fractionalPage = self.scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage))
        self.pageControl.currentPage = page
    }
    
    func entryDidFinishLoading(entry: Entry) {
        
    }
}
























