//
//  SchoolSearchViewController.swift
//  Meal
//
//  Created by 전수열 on 1/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import Alamofire
import UIKit

class SchoolSearchViewController: UIViewController {

    let tableView = UITableView()
    let searchBar = UISearchBar()
    var schools = [School]()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
        self.title = "학교 선택"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Cancel,
            target: self,
            action: "cancelButtonDidTap"
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .whiteColor()

        self.tableView.frame = self.view.bounds
        self.tableView.contentInset.top = 44
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.registerClass(SchoolCell.self, forCellReuseIdentifier: "cell")

        self.searchBar.frame.origin.y = 64
        self.searchBar.frame.size.width = self.view.frame.width
        self.searchBar.frame.size.height = 44
        self.searchBar.placeholder = "학교 검색"
        self.searchBar.delegate = self

        self.view.addSubview(self.tableView)
        self.view.addSubview(self.searchBar)
    }

    func cancelButtonDidTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func searchSchools(query: String) {
        let URLString = "http://schoool.kr/school/search"
        let parameters = ["query": query]

        Alamofire.request(.GET, URLString, parameters: parameters).responseJSON { response in
            guard let dicts = response.result.value?["data"] as? [[String: AnyObject]] else {
                return
            }
            self.schools = dicts.flatMap {
                guard let code = $0["code"] as? String else { return nil }
                guard let type = $0["type"] as? String else { return nil }
                guard let name = $0["name"] as? String else { return nil }
                guard let address = $0["address"] as? String else { return nil }
                return School(code: code, type: type, name: name, address: address)
            }
            self.tableView.reloadData()
        }
    }

}


// MARK: - UISearchBarDelegate

extension SchoolSearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let query = searchBar.text where !query.isEmpty else {
            return
        }
        self.searchSchools(query)
        searchBar.resignFirstResponder()
    }

}


// MARK: - UITableViewDataSource

extension SchoolSearchViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.schools.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let school = self.schools[indexPath.row]
        cell.textLabel?.text = school.name
        cell.detailTextLabel?.text = school.address
        cell.accessoryType = .DisclosureIndicator
        return cell
    }

}


// MARK: - UITableViewDelegate

extension SchoolSearchViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let school = self.schools[indexPath.row]
        let dict = [
            "code": school.code,
            "type": school.type,
            "name": school.name,
            "address": school.address,
        ]
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "SavedSchool")
        NSUserDefaults.standardUserDefaults().synchronize()

        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
