//
//  MealListViewController.swift
//  Meal
//
//  Created by 전수열 on 1/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import Alamofire
import UIKit

class MealListViewController: UIViewController {

    let tableView = UITableView()
    var meals = [Meal]()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
        self.title = "선린인터넷고등학교"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "바꾸기",
            style: .Plain,
            target: self,
            action: "changeButtonDidTap"
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.frame.size = self.view.frame.size
        self.tableView.registerClass(MealCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)

        self.loadMeals()
    }

    func loadMeals() {
        let schoolCode = "B100000658" // 선린인터넷고등학교
        let URLString = "http://schoool.kr/school/\(schoolCode)/meals"
        let parameters = [
            "year": 2015,
            "month": 11,
        ]

        Alamofire.request(.GET, URLString, parameters: parameters).responseJSON { response in
            guard let dicts = response.result.value?["data"] as? [[String: AnyObject]] else {
                return
            }
            self.meals = dicts.flatMap {
                guard let date = $0["date"] as? String else {
                    return nil
                }
                let lunch = $0["lunch"] as? [String] ?? []
                let dinner = $0["dinner"] as? [String] ?? []
                guard !lunch.isEmpty && !dinner.isEmpty else {
                    return nil
                }
                return Meal(date: date, lunch: lunch, dinner: dinner)
            }
            self.tableView.reloadData()
        }
    }

    func changeButtonDidTap() {
        let schoolSearchViewController = SchoolSearchViewController()
        let navigationController = UINavigationController(rootViewController: schoolSearchViewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }

}


// MARK: - UITableViewDataSource

extension MealListViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.meals.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.meals[section].date
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let meal = self.meals[section]
        return Int(!meal.lunch.isEmpty) + Int(!meal.dinner.isEmpty)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! MealCell
        let meal = self.meals[indexPath.section]
        if indexPath.row == 0 {
            cell.titleLabel.text = "점심"
            cell.contentLabel.text = meal.lunch.joinWithSeparator(", ")
        } else {
            cell.titleLabel.text = "저녁"
            cell.contentLabel.text = meal.dinner.joinWithSeparator(", ")
        }
        return cell
    }

}


// MARK: - UITableViewDelegate

extension MealListViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let meal = self.meals[indexPath.section]
        let mealType: MealCell.MealType
        if indexPath.row == 0 {
            mealType = .Lunch
        } else {
            mealType = .Dinner
        }
        return MealCell.cellHeightThatFitsWidth(tableView.frame.width, forMeal: meal, mealType: mealType)
    }

}
