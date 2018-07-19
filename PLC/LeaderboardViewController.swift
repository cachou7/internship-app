//
//  SecondViewController.swift
//  PLC
//
//  Created by Chris on 6/25/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    
    var leaderboardPageViewController: LeaderboardPageViewController? {
        didSet {
            leaderboardPageViewController?.leaderboardDelegate = self as LeaderboardPageViewControllerDelegate
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.addTarget(self, action: Selector(("didChangePageControlValue")), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let leaderboardPageViewController = segue.destination as? LeaderboardPageViewController {
            self.leaderboardPageViewController = leaderboardPageViewController
        }
    }
    
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
        leaderboardPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }


}

extension LeaderboardViewController: LeaderboardPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
    
    func pageViewController(pageViewController: LeaderboardPageViewController,
                                    didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
}

