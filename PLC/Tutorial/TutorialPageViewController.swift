//
//  TutorialPageViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 8/6/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController, TutorialPageViewControllerDelegate {
    
    //MARK: Properties
    var tutorialDelegate: TutorialPageViewControllerDelegate?
    var pageControl = UIPageControl()
    var segueFromController: String?
    
    //Initializes orderedViewControllers with TutorialViewControllers to populate page view
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newTutorialViewController(tutorialType: "Roles"),
                self.newTutorialViewController(tutorialType: "FreshEggs"),
                self.newTutorialViewController(tutorialType: "Search"),
                self.newTutorialViewController(tutorialType: "Leaderboard")]
    }()
    
    //Instantiates TutorialViewControllers
    private func newTutorialViewController(tutorialType: String) -> UIViewController {
        return (storyboard?.instantiateViewController(withIdentifier: "\(tutorialType)TutorialViewController"))!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets the segueFromController in the LeaderboardTutorialViewController so when the 'Done' button is clicked, the pages segues to it's previous view
        (orderedViewControllers[3] as? LeaderboardTutorialViewController)?.segueFromController = self.segueFromController
        
        dataSource = self
        delegate = self
        
        //Sets initial view to the first view controller in orderedViewControllers
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
        configurePageControl()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Helper Function
    private func configurePageControl() {
        // The total number of pages that are available is based on how many available view controllers we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: self.view.frame.minY + 650,width: self.view.frame.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
}

//MARK: TutorialPageViewController delegate
protocol TutorialPageViewControllerDelegate: class {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didUpdatePageIndex index: Int)
    
}

extension TutorialPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didUpdatePageIndex index: Int) {
        return
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController )!
    }
    
}

// MARK: UIPageViewControllerDataSource
extension TutorialPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController ) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex + 1
        
        // User is on the first view controller and swiped left 
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController ) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex - 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        if nextIndex >= 0{
            return orderedViewControllers[nextIndex]
        }
        else{
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

