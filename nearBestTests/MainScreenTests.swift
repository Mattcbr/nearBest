//
//  MainScreenTests.swift
//  nearBestTests
//
//  Created by Matheus Queiroz on 05/08/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import XCTest
@testable import nearBest

class MainScreenTests: XCTestCase {

    var mainView: MainScreenView?
    var mainController: MainScreenController?
    var testPlace = PlaceModel(newId: "testable",
                               newName: "Test Place",
                               newRating: 5.0,
                               newRatingsCount: 3,
                               newIsFavorite: false,
                               newPhotoReference: "photoRef")
    
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        mainView = storyboard.instantiateViewController(withIdentifier: "mainScreenView") as? MainScreenView
        _ = mainView?.view
        
        mainController = mainView?.controller
    }

    override func tearDown() {
        mainView = nil
        mainController = nil
    }

    func testFavoritesStoring() {
        let testPlacesArray = [testPlace, testPlace, testPlace]
        mainController?.didFinishLoadingFavorites(favorites: testPlacesArray)
        XCTAssertEqual(mainController?.favoritePlaces?.count, testPlacesArray.count)
    }

    func testFavoritesBoolVariable() {
        let testPlacesArray = [testPlace, testPlace, testPlace]
        mainController?.didFinishLoadingFavorites(favorites: testPlacesArray)
        XCTAssertTrue(mainController?.isDBRead ?? false)
    }
    
    func testFavoritesButtonHidden() {
        mainController?.isDBRead = true
        mainController?.isLocationSet = true
        
        mainController?.favoritePlaces = nil
        
        mainController?.verifyIfFirstLoadsAreFinished()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        
        XCTAssertTrue(mainController?.view?.favoritesButton.isHidden ?? false)
    }
    
    func testFavoritesButtonShown() {
        mainController?.isDBRead = true
        mainController?.isLocationSet = true
        
        mainController?.favoritePlaces = [testPlace]
        
        mainController?.verifyIfFirstLoadsAreFinished()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        
        XCTAssertFalse(mainController?.view?.favoritesButton.isHidden ?? true)
    }
}
