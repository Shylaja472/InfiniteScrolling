//
//  HTTPRequestManager.swift
//  FlickrAPISearch
//
//  Created by Shylaja Mamidala on 27/09/18.
//  Copyright © 2018 Shylaja Mamidala. All rights reserved.
//

import UIKit

final class HTTPRequestManager: NSObject {
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchFlickrPhotos(with text: String, page: Int , success: ((_ response: PagedPhotosResponse) -> Void)?, failure: ((_ error: Error) -> Void)?) {
        
        let imageUrlString = String(format: "%@&page=%d", ServerConfig.imageSearchUrl, page)
        
        var urlRequest = URLRequest(url: URL.init(string: imageUrlString)!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode
                else {
                    failure!(error!)
                    return
            }
            do {
                let photosResponse = try JSONDecoder().decode(PagedPhotosResponse.self, from: data!)
                if photosResponse.photos.page > 1 {
                    
                }
                print(photosResponse)
                success!(photosResponse)
            }catch let error {
                print(error.localizedDescription)
                failure!(error)
            }

        }).resume()
    }
}
