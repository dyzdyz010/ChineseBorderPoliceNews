//
//  ViewController.swift
//  FrontierPoliceNews
//
//  Created by Du Yizhuo on 16/1/26.
//  Copyright © 2016年 MLTT. All rights reserved.
//

import UIKit
import SwiftDate


class HomeViewController: UITableViewController, EntryDelegate {
    
    var date: NSDate = NSDate()
    var paper: Paper? = nil
    var currentPage = 0
    
    let entryCellIdentifier = "entryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupRefreshControl()
        loadPaper()
    }
    
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl = refreshControl
        self.tableView.addSubview(refreshControl)
    }
    
    func refresh(sender: AnyObject) {
        loadPage()
    }
    
    func loadPaper() {
        self.refreshControl?.beginRefreshing()
        Paper.fetchPaper(self.date) { (paper) -> () in
            if paper == nil {
                self.date = self.date - 1.days
                self.loadPaper()
                return
            }
            
            self.paper = paper
            self.loadPage()
            
            self.setupTitleMenu()
//            self.makeBackground()
        }
    }
    
    func loadPage() {
        self.paper?.pages[currentPage].load({ page in
            self.paper?.pages[self.currentPage] = page!
//            print(page?.entries.count)
            self.tableView.reloadData()
            page?.loadEntries(self)
            
            if ((self.refreshControl?.refreshing) != nil) {
                self.refreshControl?.endRefreshing()
            }
        })
    }
    
    func setupTitleMenu() {
        let menuItems = (paper?.pages.map{$0.title})!
        //        print(menuItems)
        let menu = BTNavigationDropdownMenu(navigationController: self.navigationController, title: menuItems[currentPage], items: menuItems)
        menu.animationDuration = 0.3
        self.navigationItem.titleView = menu
        
        menu.didSelectItemAtIndexHandler = { indexPath in
            //            print(indexPath)
            
            self.currentPage = indexPath
            self.loadPage()
        }
    }
    
    func makeBackground() {
        let img = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("logo", ofType: "png")!)
        
        let bgView = UIImageView()
//        bgView.yy_imageURL = NSURL(fileURLWithPath: "bg.jpeg")
        bgView.image = img
        bgView.contentMode = .ScaleAspectFill
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bgView.bounds
        bgView.addSubview(blurView)
        
        self.tableView.backgroundView = bgView
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let p = paper {
            //            print("entries: \(p.pages[currentPage].entries.count)")
            
            return p.pages[currentPage].entries.count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(entryCellIdentifier, forIndexPath: indexPath) as! EntryCell
        
        let titleLabel = cell.titleLabel
        let authorLabel = cell.authorLabel
        let viewCountLabel = cell.viewCountLabel
        let coverImageView = cell.coverImageView
        let entry = paper?.pages[currentPage].entries[indexPath.row]
        
        titleLabel.text = entry!.title
        authorLabel.text = entry!.author
        viewCountLabel.text = entry!.viewCount
        if entry!.images.count != 0 {
            coverImageView.yy_imageURL = entry?.images[0]
        } else {
            coverImageView.image = UIImage(named: "News")
        }
        
        return cell
    }
    
    override     
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "entry" {
            let indexPath = self.tableView.indexPathForSelectedRow!
            
            let vc = segue.destinationViewController as! EntryViewController
            vc.entry = self.paper?.pages[currentPage].entries[indexPath.row]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func entryDidFinishLoading(entry: Entry) {
        let indexPath = NSIndexPath(forRow: entry.index-1, inSection: 0)
        let rowNum = tableView(self.tableView, numberOfRowsInSection: 0)
        if indexPath.row >= rowNum {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
    }
}

