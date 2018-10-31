//
//  PhotoCollectionViewCell.swift
//  FlickrAPISearch
//
//  Created by Shylaja Mamidala on 27/09/18.
//  Copyright © 2018 Shylaja Mamidala. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    var imageUrl: String!
    
    override func prepareForReuse() {
        imageView.image = UIImage.init(named: "image_placeholder")
        imageView.image = nil
        title.text = ""
    }
}
