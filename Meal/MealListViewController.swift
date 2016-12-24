//
//  MealListViewController.swift
//  Meal
//
//  Created by 전수열 on 1/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import Alamofire
import SnapKit
import UIKit

class MealListViewController: UIViewController {

  let tableView = UITableView()
  let toolbar = UIToolbar()
  let todayButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

  var school: School? {
    didSet {
      self.title = self.school?.name ?? "학교를 선택해주세요"
      if oldValue?.code != self.school?.code {
        self.loadMeals()
      }
    }
  }
  var date: (year: Int, month: Int) {
    didSet {
      self.todayButton.title = "\(self.date.year)년 \(self.date.month)월"
      self.loadMeals()
    }
  }

  var currentRequest: Request?
  var meals = [Meal]()

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    let components = Calendar.current.dateComponents([.year, .month], from: Date())
    self.date = (year: components.year!, month: components.month!)

    super.init(nibName: nil, bundle: nil)

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "바꾸기",
      style: .plain,
      target: self,
      action: #selector(MealListViewController.changeButtonDidTap)
    )

    self.toolbar.items = [
      UIBarButtonItem(title: "이전 달", style: .plain, target: self, action: #selector(prevMonthButtonDidTap)),
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      self.todayButton,
      UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
      UIBarButtonItem(title: "다음 달", style: .plain, target: self, action: #selector(nextMonthButtonDidTap)),
    ]
    self.todayButton.title = "\(self.date.year)년 \(self.date.month)월"
    self.todayButton.tintColor = .black
    self.todayButton.isEnabled = false
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white

    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.separatorInset.left = 50
    self.tableView.contentInset.bottom = 44
    self.tableView.scrollIndicatorInsets.bottom = self.tableView.contentInset.bottom
    self.tableView.register(MealCell.self, forCellReuseIdentifier: "cell")

    self.view.addSubview(self.tableView)
    self.view.addSubview(self.toolbar)
    self.view.addSubview(self.activityIndicatorView)

    self.tableView.snp.makeConstraints { make in
      make.edges.equalTo(0)
    }

    self.toolbar.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(0)
      make.height.equalTo(44)
    }

    self.activityIndicatorView.snp.makeConstraints { make in
      make.center.equalTo(self.tableView)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.school = self.savedSchool()
  }

  func savedSchool() -> School? {
    let userDefaults = UserDefaults.standard
    guard let dict = userDefaults.object(forKey: "SavedSchool") as? [String: Any] else { return nil }
    guard let code = dict["code"] as? String else { return nil }
    guard let type = dict["type"] as? String else { return nil }
    guard let name = dict["name"] as? String else { return nil }
    return School(code: code, type: type, name: name)
  }

  func loadMeals() {
    guard let school = self.school else {
      return
    }

    self.tableView.isHidden = true
    self.activityIndicatorView.startAnimating()
    self.currentRequest?.task?.cancel()

    let urlString = "http://schoool.xoul.kr/school/\(school.code)/meals"
    let parameters = [
      "year": self.date.year,
      "month": self.date.month,
    ]

    self.currentRequest = Alamofire.request(urlString, method: .get, parameters: parameters)
      .responseJSON { response in
        guard let json = response.result.value as? [String: [[String: Any]]],
          let dicts = json["data"]
        else { return }
        self.meals = dicts.flatMap {
          guard let date = $0["date"] as? String else {
            return nil
          }
          let lunch = $0["lunch"] as? [String] ?? []
          let dinner = $0["dinner"] as? [String] ?? []
          guard !lunch.isEmpty || !dinner.isEmpty else {
            return nil
          }
          return Meal(date: date, lunch: lunch, dinner: dinner)
        }

        self.tableView.isHidden = false
        self.tableView.reloadData()
        self.activityIndicatorView.stopAnimating()
      }
  }

  func changeButtonDidTap() {
    let schoolSearchViewController = SchoolSearchViewController()
    let navigationController = UINavigationController(rootViewController: schoolSearchViewController)
    self.present(navigationController, animated: true, completion: nil)
  }

  func prevMonthButtonDidTap() {
    var date = self.date
    date.month -= 1
    if date.month <= 0 {
      date.year -= 1
      date.month = 12
    }
    self.date = date
  }

  func nextMonthButtonDidTap() {
    var date = self.date
    date.month += 1
    if date.month >= 13 {
      date.year += 1
      date.month = 1
    }
    self.date = date
  }

}


// MARK: - UITableViewDataSource

extension MealListViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return self.meals.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.meals[section].date
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let meal = self.meals[section]
    var rows: Int = 0
    if !meal.lunch.isEmpty {
      rows += 1
    }
    if !meal.dinner.isEmpty {
      rows += 1
    }
    return rows
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MealCell
    let meal = self.meals[indexPath.section]
    if indexPath.row == 0 && !meal.lunch.isEmpty {
      cell.titleLabel.text = "점심"
      cell.contentLabel.text = meal.lunch.joined(separator: ", ")
    } else {
      cell.titleLabel.text = "저녁"
      cell.contentLabel.text = meal.dinner.joined(separator: ", ")
    }
    return cell
  }

}


// MARK: - UITableViewDelegate

extension MealListViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let meal = self.meals[indexPath.section]
    let mealType: MealCell.MealType
    if indexPath.row == 0 {
      mealType = .lunch
    } else {
      mealType = .dinner
    }
    return MealCell.cellHeightThatFitsWidth(tableView.frame.width, forMeal: meal, mealType: mealType)
  }

}
