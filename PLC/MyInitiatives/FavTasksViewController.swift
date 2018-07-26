//
//  FavTasksViewController.swift
//  PLC
//
//  Created by Chris on 7/3/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class FavTasksViewController: UIViewController {
    
    @IBOutlet weak var topStackView: UIStackView!
    fileprivate var calendarViewController: CalendarViewController?
    fileprivate var favTasksTableViewController: FavTasksTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationItem.titleView?.backgroundColor = UIColor.black
        topStackView.axis = axisForSize(view.bounds.size)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let calendarController = destination as? CalendarViewController {
            calendarViewController = calendarController
        }
        
        if let favTasksTableController = destination as? FavTasksTableViewController {
            favTasksTableViewController = favTasksTableController
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        topStackView.axis = axisForSize(size)
    }
    
    private func axisForSize(_ size: CGSize) -> UILayoutConstraintAxis {
        return size.width > size.height ? .horizontal : .vertical
    }
}
