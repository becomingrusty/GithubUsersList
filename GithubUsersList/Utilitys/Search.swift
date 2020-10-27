//
//  Search.swift
//  GithubUsersList
//
//  Created by Rusty on 2020/10/27.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
  
  enum State {
    case notSearchedYet
    case loading
    case noResults
    case results([User])
  }
  private(set) var state: State = .notSearchedYet
  
  private var dataTask: URLSessionDataTask?
  
  private func searchURL(searchText: String) -> URL {
    let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let urlString = String(format: "https://api.github.com/search/users?q=%@&page=1", encodedText)
    let url = URL(string: urlString)
    return url!
  }
  
  private func parse(data: Data) -> [User] {
    do {
      let decoder = JSONDecoder()
      let result = try decoder.decode(UserArray.self, from: data)
      return result.users
    } catch {
      print("JSON Error: \(error)")
      return []
    }
  }

  func performSearch(for text: String, completion: @escaping SearchComplete) {
    if !text.isEmpty {
      dataTask?.cancel()
      state = .loading
      let url = searchURL(searchText: text)
      let session = URLSession.shared
      dataTask = session.dataTask(with: url, completionHandler: {
        data, response, error in
        var newState = State.notSearchedYet
        var success = false
        if let error = error as NSError?, error.code == -999 {
          return
        }
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200, let data = data {
          let users = self.parse(data: data)
          if users.isEmpty {
            newState = .noResults
          } else {
            newState = .results(users)
          }
          success = true
        }
        DispatchQueue.main.async {
          self.state = newState
          completion(success)
        }
      })
      dataTask?.resume()
    }
  }
  
  
  
  
  
  
}
