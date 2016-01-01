//
//  SchoolSearchViewController.swift
//  Meal
//
//  Created by 전수열 on 1/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

class SchoolSearchViewController: UIViewController {

    let tableView = UITableView()
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
        self.view.addSubview(self.tableView)
    }

    func cancelButtonDidTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
