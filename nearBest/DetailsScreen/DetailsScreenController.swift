//
//  DetailsScreenController.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import Foundation
import UIKit

protocol DetailsScreenControllerDelegate: class{
    func reloadFavoritePlaces()
}

class DetailsScreenController: RequestDelegate {
    
    let requestManager = RequestManager()
    var view: DetailsScreenView
    var placesArray = [PlaceModel]()
    let dbManager = DataBaseManager.sharedInstance
    var delegate: DetailsScreenControllerDelegate?
    
    init(view: DetailsScreenView, delegate: DetailsScreenControllerDelegate, favorites: [PlaceModel]?) {
        self.view = view
        self.delegate = delegate
        requestManager.delegate = self
        if let category = view.screenType {
            
            var navigationTitle = "Best \(category)s around"
            if let favoritePlaces = favorites{
                didLoadPlaces(places: favoritePlaces)
                 navigationTitle = "Your Favorites"
            } else if let latitude = view.lat, let longitude = view.long {
                var adjustedCategory = category.replacingOccurrences(of: " ", with: "_")
                adjustedCategory = adjustedCategory.lowercased()
                requestManager.makeFirstRequest(category: adjustedCategory, lat: latitude, long: longitude)
            }
            self.view.setupNavigation(withTitle: navigationTitle)
        }
    }
    
    //MARK: RequestDelegate
    
    func didLoadPlaces(places: [PlaceModel]) {
        if(placesArray.count == 0) {
            placesArray = places
        } else {
            placesArray.append(contentsOf: places)
        }
        view.didLoadPlaces()
    }
    
    func didFailToLoadPlaces(withError error: Error) {
        //TODO: Error Handling
    }
    
    //MARK: Request More Places
    func requestMorePlaces(){
        requestManager.requestNextPage()
    }
    
    //MARK: Request Images
    func loadImage(forPlace place:PlaceModel, completion: @escaping (_ image: UIImage) -> Void){
        if let reference = place.photoReference {
            requestManager.requestPicture(photoReference: reference) { (newThumbnail) in
                completion(newThumbnail)
            }
        } else {
            let newThumbnail = UIImage(named: "thumb_not_available")
            if let notAvailablePlaceHolder = newThumbnail {
                completion(notAvailablePlaceHolder)
            }
        }
    }
    
    //MARK: Favorite Places Management
    
    public func didPressFavorite(forPlaceAt index: Int){
        let placeToChangeFavoriteStatus = placesArray[index]
        if (placeToChangeFavoriteStatus.isFavorite) {
            self.view.showRemoveFromFavoritesAlert(forPlace: placeToChangeFavoriteStatus)
        } else {
            placesArray[index].isFavorite = !placesArray[index].isFavorite
            dbManager.addToFavorites(place: placeToChangeFavoriteStatus)
            self.view.didChangeFavoriteStatus(forElementAt: index)
            self.delegate?.reloadFavoritePlaces()
        }
    }
    
    public func removeFromFavorites(place: PlaceModel){
        print("Okay, removing \(place.name) from favorites")
        if let index = placesArray.lastIndex(of: place) {
            placesArray[index].isFavorite = !placesArray[index].isFavorite
            self.view.didChangeFavoriteStatus(forElementAt: index)
        }
        dbManager.removeFromFavorites(place: place)
        self.delegate?.reloadFavoritePlaces()
    }
}
