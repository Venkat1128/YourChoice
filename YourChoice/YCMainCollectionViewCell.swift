//
//  YCMainCollectionViewCell.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 20/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit

class YCMainCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
