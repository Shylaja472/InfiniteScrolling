//
//  File.swift
//  FlickrAPISearch
//
//  Created by Shylaja Mamidala on 04/10/18.
//  Copyright © 2018 Shylaja Mamidala. All rights reserved.
//

import Foundation

struct PagedPhotosResponse: Decodable {
    var photos: Images
    var stat: String
}
    
struct Images: Decodable {
    var photo: [Photo]
    var page: Int
    var pages: Int
    var perpage: Int
    var total: String
}
