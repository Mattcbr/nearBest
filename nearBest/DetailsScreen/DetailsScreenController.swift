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
    
    /**
     This function adds the newly loaded places to the places array.
     - Parameter places: The newly loaded places.
     */
    func didLoadPlaces(places: [PlaceModel]) {
        if(placesArray.count == 0) {
            placesArray = places
        } else {
            placesArray.append(contentsOf: places)
        }
        view.didLoadPlaces()
    }
    
    /**
     This function warns the view that there was an error while loading new places.
     - Parameter error: The error that happened while loading new places.
     */
    func didFailToLoadPlaces(withError error: Error) {
        self.view.showErrorAlert(error: error)
    }
    
    //MARK: Request More Places
    
    /**
     This function asks the request manager to load more places.
     */
    func requestMorePlaces(){
        requestManager.requestNextPage()
    }
    
    //MARK: Request Images
    
    /**
     This function loads the image for a specific place. If the place does not have a photo reference, it returns a default image.
     - Parameter place: The place for which the image should be loaded.
     - Parameter completion: The callback called after retrieval of the image.
     - Parameter image: The image that was loaded.
     */
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
    
    /**
     This function verifies if the selected place is a favorite and decides if should add it to the favorite places or if should give the user a confirmation alert about removing it from the favorites.
     - Parameter index: The index of the place on which the favorites button was pressed.
     */
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
    
    /**
     This function effectively removes a place from the favorite places.
     - Parameter place: The place that should be removed from the favorite places.
     */
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
