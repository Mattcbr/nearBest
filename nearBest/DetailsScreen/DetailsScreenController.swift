//
//  DetailsScreenController.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import Foundation

class DetailsScreenController: RequestDelegate {
    
    let requestManager = RequestManager()
    var view: DetailsScreenView
    var placesArray = [PlaceModel]()
    
    init(view: DetailsScreenView) {
        self.view = view
        requestManager.delegate = self
        if let category = view.screenType {
            //TODO: There should be a function for this
            self.view.navigationItem.title = "Best \(category)s around"
            
            if let latitude = view.lat, let longitude = view.long {
                requestManager.makeFirstRequest(category: category, lat: latitude, long: longitude)
            }
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
}
