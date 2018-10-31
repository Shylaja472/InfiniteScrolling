//
//  HTTPURLResponse.swift
//  FlickrAPISearch
//
//  Created by Shylaja Mamidala on 28/09/18.
//  Copyright © 2018 Shylaja Mamidala. All rights reserved.
//

import Foundation
extension HTTPURLResponse {
    var hasSuccessStatusCode: Bool {
        return 200...299 ~= statusCode
    }
}
