//
//  InitiativesPageViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 8/1/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit

class InitiativesPageViewController: UIPageViewController, InitiativesPageViewControllerDelegate {
    
    //MARK: Properties
    var initiativesDelegate: InitiativesPageViewControllerDelegate?
    var pageControl = UIPageControl()
    
    //Initializes orderedViewControllers with InitiativesNavigationControllers to populate page view
    private(set) lazy var orderedViewControllers: [UINavigationController] = {
        return [self.newInitiativesViewController(pageType: "FavInitiatives"),
                self.newInitiativesViewController(pageType: "RecentlyCreated")]
    }()
    
    //Instantiates InitiativesNavigationControllers
    private func newInitiativesViewController(pageType: String) -> UINavigationController {
        
        if pageType == "FavInitiatives"{
            let storyboard = UIStoryboard(name: "FavInitiatives", bundle: nil)
            return (storyboard.instantiateViewController(withIdentifier: "\(pageType)NavigationController")) as! UINavigationController
        }
        else{
            let destinationNC = (storyboard?.instantiateViewController(withIdentifier: "\(pageType)NavigationController"))! as! UINavigationController

            return destinationNC
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self as UIPageViewControllerDataSource
        delegate = self as UIPageViewControllerDelegate
        
        //Sets initial view to the first navigation controller in orderedViewControllers
        let firstViewController = orderedViewControllers[1]
        setViewControllers([firstViewController],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        configurePageControl()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Helper Function
    private func configurePageControl() {
        // The total number of pages that are available is based on how many available navigation controllers we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: self.view.frame.minY + 650,width: self.view.frame.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
}

//MARK: InitiativesPageViewController delegate
protocol InitiativesPageViewControllerDelegate: class {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didUpdatePageIndex index: Int)
    
}

extension InitiativesPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didUpdatePageIndex index: Int) {
        return
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController as! UINavigationController)!
    }
    
}

// MARK: UIPageViewControllerDataSource

extension InitiativesPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! UINavigationController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex + 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard orderedViewControllers.count != previousIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! UINavigationController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex - 1
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard nextIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
