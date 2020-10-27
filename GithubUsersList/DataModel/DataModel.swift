//
//  User.swift
//  GithubUsersList
//
//  Created by Rusty on 2020/10/26.
//
import UIKit

class UserArray: Codable {
  var total_count = 0
  var users = [User]()
  
  enum CodingKeys: String, CodingKey {
    case users = "items"
    case total_count
  }
}

class User: Codable, CustomStringConvertible {
  var login: String? = ""
  var score: Float = 0
  var html_url: String? = ""
  var avatar_url: String? = ""
  
  var description: String {
    return "\nItem - Login: \(login ?? ""), Score: \(score), URL: \(html_url ?? ""), AvatarURL: \(avatar_url ?? "")"
  }
}
