//
//  DetailsScreenTests.swift
//  nearBestTests
//
//  Created by Matheus Queiroz on 05/08/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import XCTest
@testable import nearBest

class DetailsScreenTests: XCTestCase {

    var mainView: MainScreenView?
    var mainController: MainScreenController?
    
    var detailsView: DetailsScreenView?
    var detailsController: DetailsScreenController?
    
    var testPlace = PlaceModel(newId: "testable",
                               newName: "Test Place",
                               newRating: 5.0,
                               newRatingsCount: 3,
                               newIsFavorite: false,
                               newPhotoReference: "photoRef")
    
    let secondTestPlace = PlaceModel(newId: "testable2",
                                     newName: "Test Place 2",
                                     newRating: 4.9,
                                     newRatingsCount: 5,
                                     newIsFavorite: true,
                                     newPhotoReference: "photoRef2")
    
    
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        mainView = storyboard.instantiateViewController(withIdentifier: "mainScreenView") as? MainScreenView
        _ = mainView?.view
        mainController = mainView?.controller
        
        detailsView = storyboard.instantiateViewController(withIdentifier: "detailsScreenView") as? DetailsScreenView
        detailsView?.delegate = mainController
        _ = detailsView?.view
        detailsController = detailsView?.controller
    }

    override func tearDown() {
        mainView = nil
        mainController = nil
        detailsView = nil
        detailsController = nil
    }

    func testPlacesAdding() {
        let firstCount = detailsController?.placesArray.count ?? 0
        let placesArray = [testPlace, testPlace, testPlace]
        detailsController?.didLoadPlaces(places: placesArray)
        let expectedValue = firstCount + placesArray.count
        
        XCTAssertEqual(expectedValue, detailsController?.placesArray.count)
    }
    
    func testAddingToFavorites(){
        let initialStatus = testPlace.isFavorite
        let placesArray = [testPlace, secondTestPlace]
        detailsController?.placesArray = placesArray
        detailsController?.didPressFavorite(forPlaceAt: 0)
        let retrievedPlace = detailsController?.placesArray[0]
        
        XCTAssertNotEqual(initialStatus, retrievedPlace?.isFavorite)
    }

    func testRemovingFromFavorites(){
        testPlace.isFavorite = true
        let initialStatus = testPlace.isFavorite
        let placesArray = [secondTestPlace, testPlace, secondTestPlace]
        detailsController?.placesArray = placesArray
        detailsController?.removeFromFavorites(place: testPlace)
        let retrievedPlace = detailsController?.placesArray[1]
        
        XCTAssertNotEqual(initialStatus, retrievedPlace?.isFavorite)
    }
    
}
