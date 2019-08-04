//
//  PlaceModel.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import Foundation

class PlaceModel: NSObject{
    let id: String?
    let name: String?
    let ratings: Double
    let ratingsCount: Int?
    
    init(newId: String?, newName: String?, newRating: Double?, newRatingsCount: Int?) {
        self.id = newId
        self.name = newName
        self.ratingsCount = newRatingsCount
        
        self.ratings = newRating ?? 0.0
    }
}
