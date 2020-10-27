//
//  ViewController.swift
//  GithubUsersList
//
//  Created by Rusty on 2020/10/26.
//

import UIKit
import SnapKit

class UsersListViewController: UIViewController {
  
  private let search = Search()
  
  lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar(frame: CGRect.zero)
    searchBar.placeholder = "Search for github user"
    searchBar.text = "swift"
    searchBar.sizeToFit()
    searchBar.delegate = self
    return searchBar
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: CGRect.zero)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.keyboardDismissMode = .interactive
    tableView.register(UserCell.self, forCellReuseIdentifier: CellIdentifiers.userCell)
    tableView.register(NoResultCell.self, forCellReuseIdentifier: CellIdentifiers.noResultCell)
    tableView.register(LoadingCell.self, forCellReuseIdentifier: CellIdentifiers.loadingCell)
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Setup view
    view.backgroundColor = .white
    navigationItem.title = "Github Users List"
    // Setup searchBar
    view.addSubview(searchBar)
    searchBar.snp.makeConstraints { (make) in
      make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
      make.height.equalTo(self.searchBar.frame.height)
    }
    // Setup tableView
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(self.searchBar.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }
    performSearch(shouldRealTime: false, page: 1)
  }
  
  func performSearch(shouldRealTime: Bool, page: Int) {
    search.performSearch(for: searchBar.text!, page: page) { success in
      if !success {
        self.showNetworkError()
      }
      self.tableView.reloadData()
    }
    tableView.reloadData()
    if !shouldRealTime {
      searchBar.resignFirstResponder()
    }
    
  }
  
  func showNetworkError() {
    let alert = UIAlertController(
      title: "Error",
      message: "There was an error accessing the internet.",
      preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }


}

extension UsersListViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch(shouldRealTime: false, page: 1)
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    performSearch(shouldRealTime: true, page: 1)
  }
}

extension UsersListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch search.state {
    case .notSearchedYet:
      return 0
    case .loading:
      return 1
    case .noResults:
      return 1
    case .hasResults:
      return search.userArray.users.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch search.state {
      case .notSearchedYet:
        fatalError("Fatal Error")
      case .loading:
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.loadingCell, for: indexPath) as! LoadingCell
        cell.indicator.startAnimating()
        return cell
      case .noResults:
        return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.noResultCell,for: indexPath)
    case .hasResults:
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.userCell,for: indexPath) as! UserCell
      let user = search.userArray.users[indexPath.row]
        cell.configure(for: user)
        return cell
      }
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    switch search.state {
    case .notSearchedYet, .loading, .noResults:
      return nil
    case .hasResults:
      return indexPath
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch search.state {
    case .notSearchedYet, .loading, .noResults:
      break
    case .hasResults:
      let userDetailController = UserDetailViewController()
      userDetailController.urlString = search.userArray.users[indexPath.row].html_url ?? "https://github.com/swift"
      self.navigationController?.pushViewController(userDetailController, animated: true)
    }
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch search.state {
    case .notSearchedYet, .loading, .noResults:
      return tableView.frame.height - 20
    case .hasResults:
      return 80
    }
  }
  
  
}
