//
//  PaperViewController.swift
//  BorderPoliceNews
//
//  Created by Du Yizhuo on 16/4/18.
//  Copyright © 2016年 MLTT. All rights reserved.
//


class PaperViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var date: NSDate = NSDate()
    var paper: Paper? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabbarHeight = self.tabBarController!.tabBar.frame.size.height
        let navibarHeight = self.navigationController!.navigationBar.frame.size.height
        scrollView.frame = CGRect(x: 0, y: navibarHeight, width: self.view.frame.width, height: self.view.frame.height - tabbarHeight - navibarHeight)
        let scrollWidth = scrollView.frame.width
        let scrollHeight = scrollView.frame.height
        
        let imgView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollWidth, height: scrollHeight))
        imgView1.image = UIImage(named: "img1")
        imgView1.contentMode = .ScaleAspectFit
        
        let imgView2 = UIImageView(frame: CGRect(x: scrollWidth, y: 0, width: scrollWidth, height: scrollHeight))
        imgView2.image = UIImage(named: "img2")
        imgView2.contentMode = .ScaleAspectFit
        
        let imgView3 = UIImageView(frame: CGRect(x: 2*scrollWidth, y: 0, width: scrollWidth, height: scrollHeight))
        imgView3.image = UIImage(named: "img3")
        imgView3.contentMode = .ScaleAspectFit
        
        let imgView4 = UIImageView(frame: CGRect(x: 3*scrollWidth, y: 0, width: scrollWidth, height: scrollHeight))
        imgView4.image = UIImage(named: "img4")
        imgView4.contentMode = .ScaleAspectFit
        
        scrollView.addSubview(imgView1)
        scrollView.addSubview(imgView2)
        scrollView.addSubview(imgView3)
        scrollView.addSubview(imgView4)
        scrollView.contentSize = CGSize(width: 4*scrollWidth, height: scrollHeight)
        scrollView.delegate = self
        pageControl.currentPage = 0
    }
}
