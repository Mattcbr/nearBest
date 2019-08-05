//
//  PlaceModel.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import Foundation
import UIKit

class PlaceModel: NSObject{
    let id: String?
    let name: String?
    let ratings: Double
    let ratingsCount: Int?
    let photoReference: String?
    var isFavorite: Bool
    var isThumbnailLoaded: Bool
    var thumbnail: UIImage?
    
    init(newId: String?, newName: String?, newRating: Double?, newRatingsCount: Int?, newIsFavorite: Bool, newPhotoReference: String?) {
        self.id = newId
        self.name = newName
        self.ratingsCount = newRatingsCount
        self.isFavorite = newIsFavorite
        self.photoReference = newPhotoReference
        self.isThumbnailLoaded = false
        
        self.thumbnail = UIImage(named: "image_loading_Icon")
        
        self.ratings = newRating ?? 0.0
    }
}
