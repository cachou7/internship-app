//
//  SearchBarViewController.swift
//  PLC
//
//  Created by Connor Eschrich on 7/26/18.
//  Copyright © 2018 Chris Chou. All rights reserved.
//

import UIKit
import YNSearch

class SearchBarViewController: YNSearchViewController, YNSearchDelegate {
    var overallItems: [Task]?
    var database: [String] = []
    var ynSearch = YNSearch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDatabase()
        
        let categories = ["Fun & Games", "Philanthropy", "Shared Interests", "Skill Building", "Other", "Lead", "Participate"]
        database.append(contentsOf: categories)
        
        ynSearch.setCategories(value: categories)
        ynSearch.setSearchHistories(value: categories)
        
        self.ynSearchinit()
        
        self.delegate = self
        
        initData(database: database)
        
        self.setYNCategoryButtonType(type: .background)
    }
    
    func configureDatabase(){
        for task in overallItems!{
            var locationWords = task.location.components(separatedBy: " ")
            for word in locationWords{
                if database.contains(word){
                    locationWords.remove(at: locationWords.index(of: word)!)
                }
            }
            database.append(contentsOf: locationWords)
            var titleWords = task.title.components(separatedBy: " ")
            for word in titleWords{
                if database.contains(word){
                    titleWords.remove(at: titleWords.index(of: word)!)
                }
            }
            database.append(contentsOf: titleWords)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func ynSearchListViewDidScroll() {
        self.ynSearchTextfieldView.ynSearchTextField.endEditing(true)
    }
    
    
    func ynSearchHistoryButtonClicked(text: String) {
        self.pushViewController(text: text)
        print(text)
    }
    
    func ynCategoryButtonClicked(text: String) {
        self.ynSearchView.ynSearchListView.ynSearch.appendSearchHistories(value: text)
        self.pushViewController(text: text)
        print(text)
    }
    
    func ynSearchListViewClicked(key: String) {
        self.pushViewController(text: key)
        print(key)
    }
    
    func ynSearchListViewClicked(object: Any) {
        print(object)
    }
    
    func ynSearchListView(_ ynSearchListView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.ynSearchView.ynSearchListView.dequeueReusableCell(withIdentifier: YNSearchListViewCell.ID) as! YNSearchListViewCell
        if let ynmodel = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? String {
            cell.searchLabel.text = ynmodel
        }
        
        return cell
    }
    
    func ynSearchListView(_ ynSearchListView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ynmodel = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? String{
                let key = ynmodel
            self.ynSearchView.ynSearchListView.ynSearchListViewDelegate?.ynSearchListViewClicked(key: key)
            self.ynSearchView.ynSearchListView.ynSearchListViewDelegate?.ynSearchListViewClicked(object: self.ynSearchView.ynSearchListView.database[indexPath.row])
            self.ynSearchView.ynSearchListView.ynSearch.appendSearchHistories(value: key)
        }
    }
    
    func pushViewController(text:String) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailSearchNavigationController") as! UINavigationController
        let childVC = vc.viewControllers[0] as! DetailSearchTableViewController
        childVC.navigationItem.title = text
        childVC.overallItems = self.overallItems
        
        self.present(vc, animated: true, completion: nil)
    }
    

}
