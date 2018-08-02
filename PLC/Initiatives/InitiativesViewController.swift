//
//  InitiativesViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 8/1/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class InitiativesViewController: UIPageViewController {
    var initiativesPageViewController: InitiativesPageViewController? {
        didSet {
            initiativesPageViewController?.initiativesDelegate = self as? InitiativesPageViewControllerDelegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let initiativesPageViewController = segue.destination as? InitiativesPageViewController {
            self.initiativesPageViewController = initiativesPageViewController
        }
    }
}
