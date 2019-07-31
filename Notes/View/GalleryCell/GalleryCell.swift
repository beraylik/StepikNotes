//
//  GalleryCell.swift
//  Notes
//
//  Created by Генрих Берайлик on 20/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }

    override func prepareForReuse() {
        imageView.image = nil
    }
    
}
