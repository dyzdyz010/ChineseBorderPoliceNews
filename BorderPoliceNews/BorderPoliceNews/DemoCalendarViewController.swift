//
//  DemoCalendarViewController.swift
//  FrontierPoliceNews
//
//  Created by Du Yizhuo on 16/3/21.
//  Copyright © 2016年 MLTT. All rights reserved.
//

import UIKit
import CVCalendar
import Alamofire

class DemoCalendarViewController: UIViewController {
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    var papersForMonth: [Bool]? = nil
    var dateManager: CVCalendarManager? = nil
    var isLoading = true
    
    var queue = [Request]()
    
    override func viewDidLoad() {
        dateManager = CVCalendarManager(calendarView: self.calendarView)
        
        monthLabel.text = CVDate(date: NSDate()).globalDescription
        
        checkPaper()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    func beginLoading() {
        self.isLoading = true
        self.loadingIndicator.hidden = !isLoading
        self.loadingIndicator.startAnimating()
    }
    
    func endLoading() {
        self.isLoading = false
        self.loadingIndicator.hidden = !self.isLoading
        self.loadingIndicator.stopAnimating()
    }
    
    func checkPaper() {
        revokeRequests()
        beginLoading()
        
        self.papersForMonth = [Bool].init(count: (dateManager?.currentDate.monthDays)!, repeatedValue: false)
        self.calendarView.contentController.refreshPresentedMonth()
        
        let cd = (dateManager?.currentDate)!
        let daysCount = dateManager?.currentDate.monthDays
        var index = 1
        
        var taskCount = 0
        while index <= daysCount {
            let date = CVDate(day: index, month: cd.month, week: cd.weekOfMonth, year: cd.year).convertedDate()!
            
            taskCount += 1
            
            let req = Paper.checkPaperAvailability(date, callback: { (exists, _) in
                if date.month != self.dateManager?.currentDate.month {
                    self.beginLoading()
                    return
                }
                
                if exists {
//                    print(date.day)
//                    self.papersForMonth?.insert(true, atIndex: date.day-1)
                    self.papersForMonth![date.day-1] = true
                }
                taskCount -= 1
                if taskCount == 0 {
                    self.calendarView.contentController.refreshPresentedMonth()
                    self.endLoading()
                }
            })
            self.queue.append(req)
            index += 1
        }
    }
    
    func revokeRequests() {
        for req in queue {
            req.cancel()
        }
        queue.removeAll()
    }
}

extension DemoCalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func shouldShowWeekdaysOut() -> Bool {
//        print("hhahahahhahahaah")
        return false
    }
    
    func shouldAnimateResizing() -> Bool {
        return true
    }
    
    func presentedDateUpdated(date: CVDate) {
        if monthLabel.text != date.globalDescription {
            monthLabel.text = date.globalDescription
        }
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        if dayView.date.month != dateManager?.currentDate.month {
            return false
        }
//        print("shouldShowOnDayView")
//        print(dayView.date.day)
        if papersForMonth == nil {
            return false
        }
        let date = dayView.date
        if papersForMonth![date.day-1] && dateManager?.currentDate.month == date.month  {
//            print("Event")
            return true
        }

        return false
        
//        Paper.checkPaperAvailability(dayView.date.convertedDate()!) { (exists, _) in
//            if exists {
//                dayView.backgroundColor = UIColor.redColor()
//            }
//        }
//        
//        return false
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [UIColor(red:0.67, green:0.16, blue:0.28, alpha:1.00)]
    }
    
    func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat {
        return 12
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        if isLoading {
            return
        }
        let date = dayView.date
        if papersForMonth![date.day-1] && dateManager?.currentDate.month == date.month && !isLoading  {
            //            print("Event")
//            print(NSDate(year: date.year, month: date.month, day: date.day))
            //        let date =
            performSegueWithIdentifier("paper", sender: dayView.date.convertedDate()!)
            
        }
    }
    
    func didShowNextMonthView(date: NSDate) {
        dateManager?.currentDate = date
        checkPaper()
    }
    
    func didShowPreviousMonthView(date: NSDate) {
//        print(date.month)
        dateManager?.currentDate = date
        checkPaper()
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "paper" {
            let vc = segue.destinationViewController as! HomeViewController
            let date = sender as! NSDate
            vc.date = date
        }
    }
    
    
    
    
}