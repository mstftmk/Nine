//
//  PlayTiles.swift
//  RandomGame
//
//  Created by Mustafa Tomak on 4.04.2020.
//  Copyright © 2020 Mustafa Tomak. All rights reserved.
//

import UIKit

class PlayTiles: UICollectionViewCell {
    @IBOutlet weak var tileNumber: UILabel!
    
    override func layoutSubviews() {
        tileNumber.layer.cornerRadius = tileNumber.frame.size.width / 2
        tileNumber.clipsToBounds = true
        tileNumber.layer.borderWidth = 3.0
        tileNumber.layer.borderColor = UIColor.white.cgColor
    }
    
}
