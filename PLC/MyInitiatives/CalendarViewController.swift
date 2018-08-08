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
    
    // Initialize selectedDate to current date
    var selectedDate = Date()
    // Set user to current user
    let user = Auth.auth().currentUser!
    // Initialize calendar variable
    fileprivate weak var calendar: FSCalendar!
    // Dictionary with key: Date and value: Number of events on that date
    var datesWithEvents: [String:Int] = [:]
    // Dictionary with key: taskId and value: Date that task occurs on
    var taskIdDate: [String:String] = [:]
    
    // yyyy-MM-dd date formatter
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MM-dd-yyyy date formatter
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    // Set calendar appearance as well as dataSource and delegate
    override func loadView() {
        
        // Initialize view
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black
        self.view = view
        
        // Initialize calendar and height of calendar
        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 400 : 300
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: height))
        
        // Calendar dataSource and delegates
        calendar.dataSource = self
        calendar.delegate = self
        
        // Customize calendar
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.backgroundColor = UIColor.white
        calendar.appearance.headerTitleColor = UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)
        calendar.appearance.selectionColor = UIColor(red: 248.0/255.0, green: 176.0/255.0, blue: 179.0/255.0, alpha: 1.0)
        calendar.appearance.weekdayTextColor = UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)
        calendar.appearance.todaySelectionColor = UIColor(red: 218.0/255.0, green: 73.0/255.0, blue: 82.0/255.0, alpha: 1.0)
        calendar.appearance.calendar.scrollEnabled = true
        self.view.addSubview(calendar)
        
        self.calendar = calendar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up listener for adding liked events to calendar view
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childAdded, with: { taskId in
            print("Fetching event for calendar...")
            // Get specific information for each liked task and add it to LikedItems, then reload data
            Constants.refs.databaseTasks.child(taskId.key).observeSingleEvent(of: .value, with: { snapshot in
                let timeInfo = snapshot.value as? [String : Any ] ?? [:]
                if timeInfo.count != 0{
                    let startTime = timeInfo["taskTimeMilliseconds"] as! TimeInterval
                    let date = NSDate(timeIntervalSince1970: startTime)
                    let dateString = self.dateFormatter.string(from: date as Date)
                    self.taskIdDate[timeInfo["taskId"] as! String] = dateString
                    let keyExists = self.datesWithEvents[dateString] != nil
                    
                    // Currently no events on this date
                    if !keyExists {
                        self.datesWithEvents[dateString] = 1
                    }
                    // Else, add to list of events on this date
                    else {
                        var currEventsOnDate = self.datesWithEvents[dateString]
                        currEventsOnDate = currEventsOnDate! + 1
                        self.datesWithEvents[dateString] = currEventsOnDate
                    }
                    
                    self.calendar.reloadData()
                }
                //***Throw error here
            })
        })
        
        // Set up listener for unliking events from calendar view
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childRemoved, with: { taskId in

            let dateString = self.taskIdDate[taskId.key] as! String
            var currEventsOnDate = self.datesWithEvents[dateString]
            
            // If only one event on that date, then set number to nil
            if self.datesWithEvents[dateString] == 1 {
                self.datesWithEvents[dateString] = nil
            }
            // Else, reduce number of events on that date by 1
            else {
                currEventsOnDate = currEventsOnDate! - 1
                self.datesWithEvents[dateString] = currEventsOnDate
            }
            // Remove event from taskIdDate dict
            self.taskIdDate.removeValue(forKey: taskId.key)
            self.calendar.reloadData()
        })
        
        let today = Date()
        let currDate = dateFormatter2.string(from: today)
        
        // Update user selected date on calendar to today in Firebase
        Constants.refs.databaseUserSelectedDate.child(user.uid).setValue(currDate)
    }
    
    // If user selected a date, then update in Firebase
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateString = self.dateFormatter2.string(from: date as Date)
        Constants.refs.databaseUserSelectedDate.child(user.uid).setValue(dateString)
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        self.calendar.reloadData()
    }
    
    // Return 1 if there are events on that date, otherwise return 0
    func calendar(_calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter.string(from: date)
        
        if self.datesWithEvents[dateString] != nil {
            return 1
        }
        return 0
    }
    
    // Display specific number of events on each date
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition){
        let dateString = dateFormatter.string(from: date)
        if (self.datesWithEvents[dateString] != nil) {
            cell.eventIndicator.numberOfEvents = self.datesWithEvents[dateString]!
            cell.eventIndicator.isHidden = false
            cell.eventIndicator.color = UIColor.black
        }
    }
}
