//
//  ViewController.swift
//  FlickrAPISearch
//
//  Created by Shylaja Mamidala on 20/09/18.
//  Copyright © 2018 Shylaja Mamidala. All rights reserved.
//

import UIKit

class FlickrSearchViewController: UIViewController {
    private enum SegueIdentifiers {
        static let photos = "FlickrPhotoGalleryViewController"
    }
    
    @IBOutlet weak var searchTextfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func SearchButtonAction(_ sender: UIButton) {

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //using storyboard segue to navigate
        if segue.identifier == SegueIdentifiers.photos {
            if segue.destination is FlickrPhotoGalleryViewController {
                Constants.searchText = searchTextfield.text!
            }
        }
    }
}

