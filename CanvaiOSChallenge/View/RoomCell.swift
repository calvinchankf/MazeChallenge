//
//  RoomCell.swift
//  CanvaiOSChallenge
//
//  Created by calvin on 17/3/2017.
//  Copyright © 2017年 me.calvinchankf. All rights reserved.
//

import UIKit

import Kingfisher

class RoomCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func display(room: Room) {
        
        guard let imageURL = room.imageURL else {
            self.imgView.image = nil
            return
        }
        
        self.imgView.kf.setImage(with: imageURL)
    }
}
