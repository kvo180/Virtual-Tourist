//
//  PhotoDetailViewController.swift
//  Virtual Tourist
//
//  Created by Khoa Vo on 12/18/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//
//  Swipe gesture logic obtained from StackOverflow at https://stackoverflow.com/questions/28696008/swipe-back-and-forth-through-array-of-images-swift


import UIKit

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var photoDetailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var photoAlbum = [Photo]()
    var imageIndex = 0
    var pageViews: [UIImageView?] = []
    
    
    // MARK: UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // Configure paged scrollview
//        scrollView.delegate = self
//        
//        let pageCount = photoAlbum.count
//        
//        pageControl.currentPage = imageIndex
//        pageControl.numberOfPages = pageCount
//        
//        for _ in 0..<pageCount {
//            pageViews.append(nil)
//        }
//        
//        let pagesScrollViewSize = scrollView.frame.size
//        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(photoAlbum.count), height: pagesScrollViewSize.height)
        
        //        loadVisiblePages()
        
        //        for photo in photoAlbum {
        //            let imageView = UIImageView(frame: CGRectMake(10, 10, scrollView.frame.width - 20, scrollView.frame.height - 160))
        //            imageView.image = photo.image
        //            scrollView.addSubview(imageView)
        
        // Configure swipe gestures
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show selected image and title
        photoDetailImageView.image = photoAlbum[imageIndex].image
        titleLabel.text = photoAlbum[imageIndex].title
    }
    
    
    // MARK: - Helper Methods
    
    //func loadVisiblePages() {
    //    // First, determine which page is currently visible
    //    let pageWidth = scrollView.frame.size.width
    //    let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
    //
    //    // Update the page control
    //    pageControl.currentPage = page
    //
    //    // Work out which pages you want to load
    //    let firstPage = page - 1
    //    let lastPage = page + 1
    //
    //    // Purge anything before the first page
    //    for var index = 0; index < firstPage; ++index {
    //        purgePage(index)
    //    }
    //
    //    // Load pages in our range
    //    for index in firstPage...lastPage {
    //        loadPage(index)
    //    }
    //
    //    // Purge anything after the last page
    //    for var index = lastPage+1; index < pageImages.count; ++index {
    //        purgePage(index)
    //    }
    
    
    func swiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            let lastIndex = photoAlbum.count - 1
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                print("user swiped right")
                
                imageIndex--
                
                if imageIndex < 0 {
                    imageIndex = lastIndex
                }
            case UISwipeGestureRecognizerDirection.Left:
                print("user swiped left")
                
                imageIndex++
                
                if imageIndex > lastIndex {
                    imageIndex = 0
                }
                
            default:
                break
            }
            
            photoDetailImageView.image = photoAlbum[imageIndex].image
            titleLabel.text = photoAlbum[imageIndex].title
        }
    }
}
