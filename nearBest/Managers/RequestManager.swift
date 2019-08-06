//
//  RequestManager.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

protocol RequestDelegate: class{
    func didLoadPlaces(places:[PlaceModel] )
    func didFailToLoadPlaces(withError error: Error)
}

class RequestManager {
    
    weak var delegate: RequestDelegate?
    let apiKey = "AIzaSyBV2SPI3UpZK1e5llkioYiFN-zy-fDRaR0"
    let parsingManager = ParsingManager.sharedInstance
    
    /**
     This function makes the first request of places.
     - Parameter category: The places category that should be requested.
     - Parameter lat: The device's latitude.
     - Parameter long: The device's longitude.
     */
    
    func makeFirstRequest(category: String, lat: Double, long: Double) {
        let requestAddress = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=1500&type=\(category)&key=\(apiKey)"
        weak var weakSelf = self
        Alamofire.request(requestAddress).responseJSON { (response) in
            switch response.result {
            case .success(let JSON):
                print("Success requesting first page")
                if let placesArray = weakSelf?.parsingManager.parsePlaces(response: JSON) {
                    let sortedPlaces = placesArray.sorted{($0.ratings > $1.ratings)}
                    weakSelf?.delegate?.didLoadPlaces(places: sortedPlaces)
                }
            case .failure(let error):
                weakSelf?.delegate?.didFailToLoadPlaces(withError: error)
            }
        }
    }
    
    /**
     This function requests the picture of a specific place.
     - Parameter photoReference: The photo reference (address) where the required image is.
     - Parameter completion: The callback called after retrieval of the image.
     - Parameter image: The requested image.
     */
    func requestPicture(photoReference: String, completion: @escaping (_ image: UIImage) -> Void){
        let requestAddress = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(apiKey)"
        Alamofire.request(requestAddress).responseImage { response in
            if let image = response.result.value {
                completion(image)
            }
        }
    }
    
    /**
     This function requests the subsequent places after a first call.
     - Precondition: a call to the *makeFirstRequest* function should be done before.
     */
    func requestNextPage(){
        if let token = parsingManager.nextPageToken {
            let requestAddress = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=\(token)&key=\(apiKey)"
            weak var weakSelf = self
            Alamofire.request(requestAddress).responseJSON{ (response) in
                switch response.result{
                case .success(let JSON):
                    print("Success requesting next page")
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
