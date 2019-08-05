//
//  MainScreenController.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import Foundation
import CoreLocation

class MainScreenController: NSObject, CLLocationManagerDelegate, DetailsScreenControllerDelegate {
    
    let locationManager = CLLocationManager()
    var lat: Double?
    var long: Double?
    
    var view: MainScreenView?
    
    var isLocationSet: Bool = false
    var isDBRead: Bool = false
    
    let dbManager = DataBaseManager.sharedInstance
    var favoritePlaces : [PlaceModel]?
    
    init(view: MainScreenView) {
        super.init()
        
        self.view = view
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        dbManager.startDB()
        dbManager.getFavoritePlaces { (favoritesArray) in
            self.didFinishLoadingFavorites(favorites: favoritesArray)
            print("Favorites Loading Finished. Favorites Count:\(favoritesArray.count)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        lat = locValue.latitude
        long = locValue.longitude
        isLocationSet = true
        verifyIfFirstLoadsAreFinished()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            view?.showLocationErrorMessage()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            print("Error determining user location authorization")
            break
        }
    }
    
    func didFinishLoadingFavorites(favorites:[PlaceModel]){
        self.favoritePlaces = favorites
        self.isDBRead = true
        verifyIfFirstLoadsAreFinished()
    }
    
    func verifyIfFirstLoadsAreFinished(){
        if(isLocationSet && isDBRead){
            view?.removeLoadingIndicators()
        }
    }
    
    //MARK: Details Controller Delegate
    func reloadFavoritePlaces() {
        dbManager.getFavoritePlaces { (favoritesArray) in
            self.didFinishLoadingFavorites(favorites: favoritesArray)
        }
    }
}
