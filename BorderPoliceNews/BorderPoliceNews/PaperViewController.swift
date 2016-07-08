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
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    var thumbImageViewArr: [UIImageView] = [UIImageView]()
    
    var date: NSDate = NSDate()
    var paper: Paper? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = date.toString(DateFormat.Custom("YYYY-MM-dd"))
        
        loadPaper()
    }
    
    @IBAction func refresh(sender: AnyObject) {
        self.date = NSDate()
        self.scrollView.removeAllSubviews()
        loadPaper()
    }
    
    func loadPaper() {
        self.loadingIndicator.hidden = false
        self.loadingIndicator.startAnimating()
        self.navigationItem.title = date.toString(DateFormat.Custom("YYYY-MM-dd"))
        
        Paper.fetchPaper(self.date) { (paper) -> () in
            if paper == nil {
                self.date = self.date - 1.days
                self.loadPaper()
                return
            }
            
            self.paper = paper
            self.setupPageScroll()
            self.loadPage()
            
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.hidden = true
        }
    }
    
    func loadPage() {
        let pageCount = self.paper!.pages.count
        for i in 0...pageCount-1 {
            self.paper?.pages[i].load({ page in
                self.flushThumb(index: i, page: page!)
                self.putEntryButtons(page!)
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
    
    func putEntryButtons(page: Page) {
        //        if page.index != 2 {
        //            return
        //        }
        let pageOffset = CGFloat(page.index-1) * self.scrollView.frame.width
        let ratio = self.scrollView.frame.width / 498
        
        for entry in page.entries {
            let pts = entry.points
//            print(pts)
            let origin = CGPoint(x: pts[0].x, y: pts[0].y + 40)
            var normPoints = [CGPoint]()
            normPoints.append(origin)
            for index in 1...pts.count-1 {
                let normPoint = CGPoint(x: pts[index].x * ratio, y: pts[index].y * ratio)
                normPoints.append(normPoint)
            }
            
            let frame = CGRect(x: origin.x*ratio + pageOffset,
                               y: origin.y*ratio,
                               width: (pts[1].x-origin.x)*ratio,
                               height: (pts[2].y-pts[1].y)*ratio)
            
            
            let button = UIButton(frame: frame)
            //            button.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 0.4)
            self.scrollView.addSubview(button)
            button.tag = page.entries.indexOf(entry)!
            
            button.addTarget(self, action: #selector(entryClicked), forControlEvents: .TouchUpInside)
        }
    }
    
    func entryClicked(sender: UIButton) {
//        print(sender.tag)
        let entry = self.paper?.pages[self.pageControl.currentPage].entries[sender.tag]
        self.performSegueWithIdentifier("entry", sender: entry)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = self.scrollView.frame.size.width
        let fractionalPage = self.scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage))
        self.pageControl.currentPage = page
    }
    
    func entryDidFinishLoading(entry: Entry) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "entry" {
            let vc = segue.destinationViewController as! EntryViewController
            vc.entry = sender as! Entry
        }
    }
}
























