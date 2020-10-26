//
//  ViewController.swift
//  GithubUsersList
//
//  Created by Rusty on 2020/10/26.
//

import UIKit
import SnapKit

class UsersListViewController: UIViewController {
  
  lazy var searchBar = UISearchBar(frame: CGRect.zero)
  lazy var tableView = UITableView(frame: CGRect.zero)

  override func viewDidLoad() {
    super.viewDidLoad()
    // Setup view
    view.backgroundColor = .white
    navigationItem.title = "Github Users List"
    // Setup searchBar
    searchBar.placeholder = "Search for github user"
    searchBar.sizeToFit()
    searchBar.delegate = self
    view.addSubview(searchBar)
    searchBar.snp.makeConstraints { (make) in
      make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
      make.height.equalTo(self.searchBar.frame.height)
    }
    // Setup tableView
    tableView.delegate = self
    tableView.dataSource = self
    tableView.keyboardDismissMode = .interactive
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(self.searchBar.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }


}

extension UsersListViewController: UISearchBarDelegate {
  
}

extension UsersListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  
}
