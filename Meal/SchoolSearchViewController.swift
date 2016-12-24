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

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
    self.title = "학교 선택"
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelButtonDidTap)
    )
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white

    self.tableView.frame = self.view.bounds
    self.tableView.contentInset.top = 44
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.register(SchoolCell.self, forCellReuseIdentifier: "cell")

    self.searchBar.placeholder = "학교 검색"
    self.searchBar.delegate = self

    self.view.addSubview(self.tableView)
    self.view.addSubview(self.searchBar)

    self.tableView.snp.makeConstraints { make in
      make.edges.equalTo(0)
    }

    self.searchBar.snp.makeConstraints { make in
      make.top.equalTo(64)
      make.width.equalTo(self.view)
      make.height.equalTo(44)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.searchBar.becomeFirstResponder()
  }

  func cancelButtonDidTap() {
    self.searchBar.resignFirstResponder()
    self.dismiss(animated: true, completion: nil)
  }

  func searchSchools(_ query: String) {
    let urlString = "http://schoool.xoul.kr/school/search"
    let parameters = ["query": query]

    Alamofire.request(urlString, method: .get, parameters: parameters)
      .responseJSON { response in
        guard let json = response.result.value as? [String: [[String: Any]]],
          let dicts = json["data"]
        else { return }
        self.schools = dicts.flatMap {
          guard let code = $0["code"] as? String else { return nil }
          guard let type = $0["type"] as? String else { return nil }
          guard let name = $0["name"] as? String else { return nil }
          return School(code: code, type: type, name: name)
        }
        self.tableView.reloadData()
      }
  }

}


// MARK: - UISearchBarDelegate

extension SchoolSearchViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text, !query.isEmpty else {
      return
    }
    self.searchSchools(query)
    searchBar.resignFirstResponder()
  }

}


// MARK: - UITableViewDataSource

extension SchoolSearchViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.schools.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    let school = self.schools[indexPath.row]
    switch school.type {
    case "유치원":
      cell.imageView?.image = UIImage(named: "icon_kinder")
    case "초등학교":
      cell.imageView?.image = UIImage(named: "icon_elementary")
    case "중학교":
      cell.imageView?.image = UIImage(named: "icon_middle")
    case "고등학교":
      cell.imageView?.image = UIImage(named: "icon_high")
    default:
      cell.imageView?.image = nil
    }
    cell.textLabel?.text = school.name
    cell.accessoryType = .disclosureIndicator
    return cell
  }

}


// MARK: - UITableViewDelegate

extension SchoolSearchViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let school = self.schools[indexPath.row]
    let dict = [
      "code": school.code,
      "type": school.type,
      "name": school.name,
      ]
    UserDefaults.standard.set(dict, forKey: "SavedSchool")
    UserDefaults.standard.synchronize()

    self.dismiss(animated: true, completion: nil)
  }

}
