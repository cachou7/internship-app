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
    
    var selectedDate = Date()
    let user = Auth.auth().currentUser!
    fileprivate weak var calendar: FSCalendar!
    var datesWithEvents: [String:Int] = [:]
    var taskIdDate: [String:String] = [:]
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
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
        //calendar.placeholderType = .none
        self.view.addSubview(calendar)
        
        self.calendar = calendar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    if !keyExists {
                        self.datesWithEvents[dateString] = 1
                    }
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
        
        
        Constants.refs.databaseUsers.child(user.uid + "/tasks_liked").observe(.childRemoved, with: { taskId in
            print("Deleting event from calendar...")
            let dateString = self.taskIdDate[taskId.key] as! String
            var currEventsOnDate = self.datesWithEvents[dateString]
            if self.datesWithEvents[dateString] == 1 {
                self.datesWithEvents[dateString] = nil
            }
            else {
                currEventsOnDate = currEventsOnDate! - 1
                self.datesWithEvents[dateString] = currEventsOnDate
            }
            self.taskIdDate.removeValue(forKey: taskId.key)
            self.calendar.reloadData()
        })
        
        let today = Date()
        let currDate = dateFormatter2.string(from: today)
        Constants.refs.databaseUserSelectedDate.child(user.uid).setValue(currDate)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateString = self.dateFormatter2.string(from: date as Date)
        Constants.refs.databaseUserSelectedDate.child(user.uid).setValue(dateString)
        
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
