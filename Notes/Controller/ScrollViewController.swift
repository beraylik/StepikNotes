//
//  ScrollViewController.swift
//  Greeting
//
//  Created by Миландр on 17/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Properties
    
    var images = [UIImage]()
    var selectedIndex = 0
    private var imageViews = [UIImageView]()
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for image in images {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var targetRect: CGRect = scrollView.frame
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = scrollView.frame.size
            imageView.frame.origin.x = scrollView.frame.width * CGFloat(index)
            imageView.frame.origin.y = 0
            if index == selectedIndex {
                targetRect = imageView.frame
            }
        }
        let contentWidth = scrollView.frame.width * CGFloat(imageViews.count)
        scrollView.contentSize = CGSize(
            width: contentWidth,
            height: scrollView.frame.height
        )
        scrollView.scrollRectToVisible(targetRect, animated: false)
    }
 
    // MARK: - Interactions
    
    func set(images: [UIImage], selectedIndex: Int = 0) {
        self.images = images
        self.selectedIndex = selectedIndex
    }
    
}

