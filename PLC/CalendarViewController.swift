//
//  CalendarViewController.swift
//  PLC
//
//  Created by Chris on 7/11/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UIGestureRecognizerDelegate {
    
    let user = Auth.auth().currentUser!
    fileprivate weak var calendar: FSCalendar!
    fileprivate weak var eventLabel: UILabel!
    var datesWithEvents: [String:Int] = [:]
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    override func loadView() {
        
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black
        self.view = view
        
        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 400 : 300
        //self.navigationController!.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0)
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: height))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.backgroundColor = UIColor.white
        self.view.addSubview(calendar)
        
        self.calendar = calendar
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childAdded, with: { taskId in
            print("Fetching fav tasks...")
            // Get specific information for each liked task and add it to LikedItems, then reload data
            Constants.refs.databaseTasks.child(taskId.key).observeSingleEvent(of: .value, with: { snapshot in
                let timeInfo = snapshot.value as? [String : Any ] ?? [:]
                let startTime = timeInfo["taskTimeMilliseconds"] as! TimeInterval
                let date = NSDate(timeIntervalSince1970: startTime)
                let dateString = self.dateFormatter.string(from: date as Date)
                let keyExists = self.datesWithEvents[dateString] != nil
                if !keyExists {
                    self.datesWithEvents[dateString] = 1
                }
                else {
                    var currEventsOnDate = self.datesWithEvents[dateString]
                    currEventsOnDate = currEventsOnDate! + 1
                    self.datesWithEvents[dateString] = currEventsOnDate
                }
                self.calendar.reloadData()
            })
        })
        
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childRemoved, with: { taskId in
            print("Deleting item from fav tasks...")
            //if self.likedItems.count > 0 {
            Constants.refs.databaseTasks.child(taskId.key).observeSingleEvent(of: .value, with: { snapshot in
                let timeInfo = snapshot.value as? [String : Any ] ?? [:]
                let startTime = timeInfo["taskTimeMilliseconds"] as! TimeInterval
                let date = NSDate(timeIntervalSince1970: startTime)
                let dateString = self.dateFormatter.string(from: date as Date)
                
                var currEventsOnDate = self.datesWithEvents[dateString]
                if self.datesWithEvents[dateString] == 1 {
                    self.datesWithEvents[dateString] = nil
                }
                else {
                    currEventsOnDate = currEventsOnDate! - 1
                    self.datesWithEvents[dateString] = currEventsOnDate
                }
                self.calendar.reloadData()
            })
            //self.calendar.reloadData()
        })
        //self.navigationController?.isNavigationBarHidden = true
        //self.title = "My Initiatives"
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        /*if (calendar.scope == FSCalendarScope.month) {
            calendar.setScope(FSCalendarScope.week, animated: true)
            calendar.select(date, scrollToDate: true)
        }
        else {
            self.navigationItem.rightBarButtonItem = nil;
        }*/
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        
        self.calendar.reloadData()
    }
    
    func calendar(_calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter.string(from: date)
        
        if self.datesWithEvents[dateString] != nil {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition){
        let dateString = dateFormatter.string(from: date)
        if (self.datesWithEvents[dateString] != nil) {
            cell.eventIndicator.numberOfEvents = self.datesWithEvents[dateString]!
            cell.eventIndicator.isHidden = false
            cell.eventIndicator.color = UIColor.black
        }
    }
}
