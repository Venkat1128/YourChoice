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
    func setImageViewProperties(){
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
        self.imageView.clipsToBounds = true;
        self.imageView.layer.borderWidth = 3.0;
        self.imageView.layer.borderColor = UIColor.white.cgColor;
    }
}
