//
//  DetailsCell.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import UIKit

class DetailsCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var totalRatingsLabel: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var bestPlaceIndicator: UIImageView!
    
    func setupForPlace(place:PlaceModel){
       
        let nameText = place.name ?? "Name not available"
        let bgcolor = UIColor(red: 0.1961, green: 0.1961, blue: 0.1961, alpha: 0.7)
        
        var ratingText: String
        if place.ratings == 0.0 {
            ratingText = "Rating not available"
        } else {
            ratingText = "Rating:\(place.ratings)"
        }
        
        
        var ratingsCountText: String
        if let ratingsCount = place.ratingsCount{
            ratingsCountText = "Rated by \(ratingsCount) people"
        } else {
            ratingsCountText = "Ratings Count Not Available"
        }
        
        nameLabel.text = nameText
        ratingLabel.text = ratingText
        totalRatingsLabel.text = ratingsCountText
        bestPlaceIndicator.isHidden = true
        
        nameLabel.backgroundColor = bgcolor
        ratingLabel.backgroundColor = bgcolor
        totalRatingsLabel.backgroundColor = bgcolor
    }
    
    func isBestAround(){
        let goldenColor = UIColor(red: 0.9294, green: 0.7176, blue: 0.2314, alpha: 0.8)
        nameLabel.backgroundColor = goldenColor
        ratingLabel.backgroundColor = goldenColor
        totalRatingsLabel.backgroundColor = goldenColor
        bestPlaceIndicator.isHidden = false
    }
}
