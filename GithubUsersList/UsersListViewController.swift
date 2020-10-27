//
//  ViewController.swift
//  GithubUsersList
//
//  Created by Rusty on 2020/10/26.
//

import UIKit
import SnapKit

class UsersListViewController: UIViewController {
  
  var users = [User]()
  
  lazy var searchBar: UISearchBar = {
    let searchBar = UISearchBar(frame: CGRect.zero)
    searchBar.placeholder = "Search for github user"
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
  
  var hasSearched = false
  var isLoading = false

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
  }
  
  func searchURL(searchText: String) -> URL {
    let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let urlString = String(format: "https://api.github.com/search/users?q=%@&page=1", encodedText)
    let url = URL(string: urlString)
    return url!
  }
  
  func performSearchRequest(with url: URL) -> Data? {
    do {
      return try Data(contentsOf: url)
    } catch  {
      print("Download Error: \(error.localizedDescription)")
      showNetworkError()
      return nil
    }
  }
  
  func parse(data: Data) -> [User] {
    do {
      let decoder = JSONDecoder()
      let result = try decoder.decode(UserArray.self, from: data)
      return result.users
    } catch {
      print("JSON Error: \(error)")
      return []
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
    if !searchBar.text!.isEmpty {
      searchBar.resignFirstResponder()
      isLoading = true
      tableView.reloadData()
      hasSearched = true
      users = []
      let queue = DispatchQueue.global()
      let url = searchURL(searchText: searchBar.text!)
      queue.async {
        if let data = self.performSearchRequest(with: url) {
          self.users = self.parse(data: data)
          DispatchQueue.main.async {
            self.isLoading = false
            self.tableView.reloadData()
          }
          return
        }
      }
    }
  }
  
}

extension UsersListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading {
      return 1
    } else if !hasSearched {
      return 0
    } else if users.count == 0 {
      return 1
    } else {
      return users.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.loadingCell, for: indexPath) as! LoadingCell
      cell.indicator.startAnimating()
      return cell
    } else if users.count == 0 {
      return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.noResultCell, for: indexPath) 
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.userCell, for: indexPath) as! UserCell
      let user = users[indexPath.row]
      cell.loginLabel.text = user.login
      cell.scoreLabel.text = formattedScoreString(score: user.score)
      cell.urlLabel.text = user.html_url
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if users.count == 0 || isLoading {
      return nil
    } else {
      return indexPath
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if users.count == 0 {
      return tableView.frame.height
    } else {
      return 80
    }
  }
  
  
}
