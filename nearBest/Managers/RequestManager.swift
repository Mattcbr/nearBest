//
//  RequestManager.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import Foundation
import Alamofire

protocol RequestDelegate: class{
    func didLoadPlaces(places:[PlaceModel] )
    func didFailToLoadPlaces(withError error: Error)
}

class RequestManager {
    
    weak var delegate: RequestDelegate?
    let apiKey = "AIzaSyBV2SPI3UpZK1e5llkioYiFN-zy-fDRaR0"
    let parsingManager = ParsingManager.sharedInstance
    
    func makeFirstRequest(category: String, lat: Double, long: Double) {
        let requestAddress = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=1500&type=\(category)&key=\(apiKey)"
//        let requestAddress = "https://nearbest-c19ec.firebaseio.com/results.json"
        weak var weakSelf = self
        Alamofire.request(requestAddress).responseJSON { (response) in
            switch response.result {
            case .success(let JSON):
                print("Okay, success on first page. Parse that shit")
                if let placesArray = weakSelf?.parsingManager.parsePlaces(response: JSON) {
                    let sortedPlaces = placesArray.sorted{($0.ratings > $1.ratings)}
                    weakSelf?.delegate?.didLoadPlaces(places: sortedPlaces)
                }
            case .failure(let error):
                print("Failure: \(error.localizedDescription)")
            }
        }
    }
    
    func requestNextPage(){
        if let token = parsingManager.nextPageToken {
            let requestAddress = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=\(token)&key=\(apiKey)"
            weak var weakSelf = self
            Alamofire.request(requestAddress).responseJSON{ (response) in
                switch response.result{
                case .success(let JSON):
                    print("Okay, success on next page. Parse that shit")
                    if let placesArray = weakSelf?.parsingManager.parsePlaces(response: JSON) {
                        let sortedPlaces = placesArray.sorted{($0.ratings > $1.ratings)}
                        weakSelf?.delegate?.didLoadPlaces(places: sortedPlaces)
                    }
                case .failure(let error):
                    print("Failure: \(error.localizedDescription)")
                }
            }
        }
    }
}
