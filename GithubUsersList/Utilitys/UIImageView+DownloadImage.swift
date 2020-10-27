//
//  UIImageView+DownloadImage.swift
//  GithubUsersList
//
//  Created by Rusty on 2020/10/27.
//

import UIKit

extension UIImageView {
  func loadImage(url: URL) -> URLSessionDownloadTask {
    let session = URLSession.shared
    let downloadTask = session.downloadTask(with: url) {
      [weak self] url, _, error in
      if error == nil, let url = url,
        let data = try? Data(contentsOf: url),
        let image = UIImage(data: data) {
        DispatchQueue.main.async {
          if let weakSelf = self {
            weakSelf.image = image
          }
        }
      }
    }
    downloadTask.resume()
    return downloadTask
  }
  
  func load(url: URL, placeholder: UIImage?, cache: URLCache? = nil) {
    let cache = cache ?? URLCache.shared
    let request = URLRequest(url: url)
    if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
      self.image = image
    } else {
      self.image = placeholder
      URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
        if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
          let cachedData = CachedURLResponse(response: response, data: data)
          cache.storeCachedResponse(cachedData, for: request)
          self.image = image
        }
      }).resume()
    }
  }
  
}
