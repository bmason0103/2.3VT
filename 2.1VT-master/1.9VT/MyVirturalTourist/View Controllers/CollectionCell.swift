//
//  CollectionCell.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/4/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell : UICollectionViewCell {
    //MARK: Outlets
//    let columns: CGFloat = 3.0
    
    var imageUrl: String = ""
 
    @IBOutlet weak var collectionImageViewCell: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}

