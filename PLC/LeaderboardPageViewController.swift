//
//  LeaderboardPageViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/3/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class LeaderboardPageViewController: UIPageViewController {
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newLeaderboardViewController(leaderboardType: "Office"),
                self.newLeaderboardViewController(leaderboardType: "Department")]
    }()
    
    private func newLeaderboardViewController(leaderboardType: String) -> UIViewController {
        return UIStoryboard(name: "\(leaderboardType)Leaderboard", bundle: nil) .
            instantiateViewController(withIdentifier: "\(leaderboardType)ViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self as UIPageViewControllerDataSource
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UIPageViewControllerDataSource

extension LeaderboardPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
}
