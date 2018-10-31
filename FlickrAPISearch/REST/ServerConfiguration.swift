//
//  ServerCofiguration.swift
//  FlickrAPISearch
//
//  Created by Shylaja Mamidala on 28/09/18.
//  Copyright © 2018 Shylaja Mamidala. All rights reserved.
//

import Foundation
struct ServerConfig {
    static let baseURL = "https://api.flickr.com/services/rest/"
    static let imageSearchUrl = String(format: "%@?method=%@&api_key=%@&safe_search=1&text=%@&format=json&nojsoncallback=1&per_page=%d",
               baseURL, Constants.imageSearchMethod, Constants.API_KEY, Constants.searchText, Constants.per_page)
}

struct Constants {
    static let API_KEY = "3e7cc266ae2b0e0d78e279ce8e361736"
    static let imageSearchMethod = "flickr.photos.search"
    static var searchText = ""
    static let per_page = 40
}

