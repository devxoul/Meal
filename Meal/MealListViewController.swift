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

    var meals = [Meal]()

    override func viewDidLoad() {
        super.viewDidLoad()
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
                return Meal(date: date, lunch: lunch, dinner: dinner)
            }
        }
    }

}

