//
//  ParsingManager.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import Foundation

class ParsingManager {
    static let sharedInstance = ParsingManager()
    
    public var nextPageToken: String?
    
    //MARK: Parsing information from the API
    
    /**
     This function parses places retrieved from the API.
     - parameter response: The API's response
     - Returns: An array with the places retrieved from the API.
     */
    func parsePlaces(response: Any) -> [PlaceModel] {
        let JSONresponse = response as? [String : Any]
        nextPageToken = JSONresponse?["next_page_token"] as? String
        let places = JSONresponse?["results"] as? [[String : Any]]
        
        var placesArray = [PlaceModel] ()
        
        let dbManager = DataBaseManager.sharedInstance
        
        places?.forEach{ newPlace in
            let id = newPlace["id"] as? String
            let name = newPlace["name"] as? String
            let rating = newPlace["rating"] as? Double
            let ratingsCount = newPlace["user_ratings_total"] as? Int
            let photoDetails = newPlace["photos"] as? [[String : Any]]
            
            var photoReference = newPlace["photo_reference"]as? String
            if(photoReference == nil){
                photoDetails?.forEach{ newDetail in
                    photoReference = newDetail["photo_reference"] as? String
                }
            }
            
            var isFavorite = false
            if let idToVerify = id {
                isFavorite = dbManager.verifyIfIsFavorite(placeID: idToVerify)
            }
            
            let newPlace = PlaceModel(newId: id,
                                      newName: name,
                                      newRating: rating,
                                      newRatingsCount: ratingsCount,
                                      newIsFavorite: isFavorite,
                                      newPhotoReference: photoReference)
            placesArray.append(newPlace)
        }
        return placesArray
    }
}
