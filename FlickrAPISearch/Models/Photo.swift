//
//  Photo.swift
//  FlickrAPISearch
//
//  Created by Shylaja Mamidala on 03/10/18.
//  Copyright © 2018 Shylaja Mamidala. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    let title: String
    let farm: Int
    let id: String
    let owner: String
    let secret: String
    let server: String
}
