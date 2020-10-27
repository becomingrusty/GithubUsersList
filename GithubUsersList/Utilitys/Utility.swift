//
//  Utility.swift
//  GithubUsersList
//
//  Created by Rusty on 2020/10/27.
//
import Foundation

func formattedScoreString(score: Float) -> String {
  let formatter = NumberFormatter()
  formatter.minimumFractionDigits = 0
  formatter.maximumFractionDigits = 2
  formatter.minimumIntegerDigits = 1
  return formatter.string(from: NSNumber(value: score))!
}
