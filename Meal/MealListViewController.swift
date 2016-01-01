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
        Alamofire
            .request(.GET, "http://schoool.kr/school/search", parameters: ["query": "선린"])
            .responseJSON { response in
                print(response.result.value)
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

