//
//  FlickrPhotoGalleryViewController.swift
//  FlickrAPISearch
//
//  Created by Shylaja Mamidala on 27/09/18.
//  Copyright © 2018 Shylaja Mamidala. All rights reserved.
//

import UIKit

class FlickrPhotoGalleryViewController: UIViewController {
    fileprivate var downloadQueue = DispatchQueue(label: "Image cache", qos: DispatchQoS.utility)

    private enum cellIdentifier {
        static let photoCellIdentifier = "PhotoCollectionViewCell"
    }
    
    @IBOutlet var photoGalleryCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var flowLayout:UICollectionViewFlowLayout! = nil
    var photosResponse: PagedPhotosResponse!
    var isRequestInProgress: Bool = false
    var newObjectsCount: Int = 0
    var photosArray: [Photo]!
    let imageCache: NSCache = NSCache<AnyObject, AnyObject>()
    let requestManager =  HTTPRequestManager.init()
    @IBOutlet weak var activityBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setup() {
        // configure collectionview layout
        flowLayout = UICollectionViewFlowLayout()
        let itemWidth = UIScreen.main.bounds.size.width/3 - 1
        flowLayout.itemSize = CGSize.init(width: itemWidth, height: itemWidth)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 1
        
        photoGalleryCollectionView.collectionViewLayout = flowLayout
        photoGalleryCollectionView.delegate = self
        photoGalleryCollectionView.dataSource = self
        
        fetchPhotos()

    }
    
    func fetchPhotos() {
        let currentPage = newObjectsCount < Constants.per_page - 2 ? 1 : photosResponse.photos.page + 1
        //If all of the photos are fetched, it will start from beginning so that infinite scrolling is supported
        isRequestInProgress = true
        activityIndicator.startAnimating()
        activityBottomConstraint.constant = 0
        requestManager.fetchFlickrPhotos(with: Constants.searchText, page: currentPage, success: { [weak self](response) in
            print(response)
            weak var weakSelf = self
            self?.newObjectsCount = response.photos.photo.count
            if weakSelf?.photosResponse != nil {
                weakSelf?.photosResponse.photos.page = response.photos.page
                weakSelf?.photosResponse.photos.pages = response.photos.pages
                weakSelf?.photosResponse.photos.perpage = response.photos.perpage
                weakSelf?.photosResponse.photos.total = response.photos.total
                weakSelf?.photosResponse.photos.photo.append(contentsOf: response.photos.photo)
                weakSelf?.photosResponse.stat = response.stat
                DispatchQueue.main.async {
                    weakSelf?.activityIndicator.stopAnimating()
                    weakSelf?.activityBottomConstraint.constant = -37
                    weakSelf?.photosArray = weakSelf?.photosResponse.photos.photo
                    weakSelf?.reloadCollectionViewData()
                }
            }else{
                weakSelf?.photosResponse = response
                weakSelf?.photosArray = weakSelf?.photosResponse.photos.photo
                DispatchQueue.main.async {
                    weakSelf?.activityIndicator.stopAnimating()
                    weakSelf?.activityBottomConstraint.constant = -37
                    weakSelf?.photoGalleryCollectionView.reloadData()
                    weakSelf?.isRequestInProgress = false
                }
            }
        }, failure: { [weak self](error) in
            self?.isRequestInProgress = false
            self?.activityIndicator.stopAnimating()
            self?.activityBottomConstraint.constant = -37
            print(error)
        })
    }
    
    deinit{
        
    }

}

extension FlickrPhotoGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = photosArray else {
            return 0
        }
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell: PhotoCollectionViewCell = self.photoGalleryCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.photoCellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        collectionViewCell.imageView.image = UIImage.init(named: "image_placeholder")
        let photoObject: Photo = photosArray[indexPath.row]
        collectionViewCell.title.text = photoObject.title
        
        let imageUrlString = String(format: "https://farm%d.static.flickr.com/%@/%@_%@.jpg", photoObject.farm, photoObject.server, photoObject.id, photoObject.secret)
        collectionViewCell.imageUrl = imageUrlString
        
        if let imageFromCache = self.imageCache.object(forKey: imageUrlString as NSString) as? UIImage {
            collectionViewCell.imageView.image = imageFromCache
        }else{
            collectionViewCell.imageView.image = UIImage.init(named: "image_placeholder")
            downloadPhotoFromObject(urlString: imageUrlString, row: indexPath.row) { (url, image, item) in
                if collectionViewCell.imageUrl == imageUrlString {
                    DispatchQueue.main.async {
                        collectionViewCell.imageView.image = image
                    }
                }
            }
        }
        
        return collectionViewCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = UIScreen.main.bounds.size.width/3 - 1
        return CGSize.init(width: itemWidth, height: itemWidth)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        if isLoadingCell(for: indexPath) && !isRequestInProgress {
            fetchPhotos()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //check whethere the image is appropriate or not
        let photoObject: Photo = photosArray[indexPath.row]
        let imageUrlString = String(format: "https://farm%d.static.flickr.com/%@/%@_%@.jpg", photoObject.farm, photoObject.server, photoObject.id, photoObject.secret)
        print(imageUrlString)
    }
}

private extension FlickrPhotoGalleryViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= photosResponse.photos.photo.count - 5
    }
    
    func reloadCollectionViewData() {
        let newIndexPathsToReload = calculateIndexPathsToReload()
        if newIndexPathsToReload.count == 0 {
            photoGalleryCollectionView.reloadData()
            return
        }

        self.photoGalleryCollectionView.performBatchUpdates({[weak self] in
            self?.photoGalleryCollectionView.insertItems(at: newIndexPathsToReload)
        }, completion: {[weak self](success) in
            self?.isRequestInProgress = false
        })
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = photoGalleryCollectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    private func calculateIndexPathsToReload() -> [IndexPath] {
        let startIndex = photosResponse.photos.photo.count - newObjectsCount
        let endIndex = startIndex + newObjectsCount
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    func downloadPhotoFromObject(urlString: String, row: Int, completion:@escaping ((_ url: URL,_ image: UIImage, _ item: Int) -> Void)) {
        let imageUrl: URL = URL.init(string: urlString)!
        weak var weakSelf = self
        self.downloadQueue.async {
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                
                guard let imageData = data, error == nil, let imageToCache = UIImage(data: imageData) else {
                    DispatchQueue.main.async {
                        weakSelf?.activityIndicator.stopAnimating()
                    }
                    return
                }
                
                weakSelf?.imageCache.setObject(imageToCache, forKey: imageUrl.absoluteString as NSString)
                completion(imageUrl, imageToCache, row)
                }.resume()
        }
    }
  
}
