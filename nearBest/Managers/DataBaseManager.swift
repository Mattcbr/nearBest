//
//  DataBaseManager.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/4/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import Foundation
import FMDB
import UIKit

class DataBaseManager {
    static let sharedInstance = DataBaseManager()
    private let latestDBversion: Int32 = 2
    
    private var dbQueue: FMDatabaseQueue?
    private let Parser = ParsingManager.sharedInstance
    private let defaultFileManager = FileManager.default
    
    /**
     This function starts the database
     */
    open func startDB() {
        if(dbQueue == nil) {
            let fileURL = try! defaultFileManager.url(for: .documentDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: false).appendingPathComponent("placesDatabase.sqlite")
            
            dbQueue = FMDatabaseQueue(path: fileURL.path)
            
        }
        verifyDBVersion()
    }
    
    /**
     This function verifies the database version and decides if the database tables should be updated, created from scratch or, if the version is already the latest, nothing should be done.
     */
    fileprivate func verifyDBVersion() {
        self.dbQueue?.inDatabase { db in
            do {
                let versionTableExists: FMResultSet = try db.executeQuery("SELECT version FROM dbVersion", values: nil)
                if (versionTableExists.next()){
                    let dbVersion: Int32 = versionTableExists .int(forColumn: "version")
                    if(dbVersion >= latestDBversion){
                        print("DB Already in latest Version")
                    } else {
                        migrateDB(fromVersion: dbVersion, db: db)
                    }
                }
            } catch {
                print("No dbVersionTable. Error: \(error.localizedDescription)")
                createDBInLatestVersion(db: db)
            }
        }
    }
    
    /**
     This function creates all the database's tables from scratch. The created tables will be in the latest version.
     - parameter db: The database where all the tables should be created
     */
    fileprivate func createDBInLatestVersion(db: FMDatabase) {
        do {
            try db.executeUpdate("CREATE TABLE IF NOT EXISTS Favorites(id TEXT PRIMARY KEY NOT NULL, name TEXT, rating REAL, ratingsCount REAL, photoReference TEXT)", values: nil)
            try db.executeUpdate("CREATE TABLE IF NOT EXISTS dbVersion(id INT PRYMARY KEY NOT NULL, version INT)", values: nil)
            updateDBVersionInTable(db: db)
            print("DB created in version: \(latestDBversion)")
        } catch {
            print("Error creating tables: \(error.localizedDescription)")
        }
    }
    
    /**
     This function migrates all the database's tables from an older version to the latest one.
     - parameter fromVersion: The actual version of the tables in the database.
     - parameter db: The database where all the tables should be updated.
     */
    fileprivate func migrateDB(fromVersion version:Int32, db: FMDatabase){
        var updatedVersion = version
        var noError = true
        switch updatedVersion {
        case 1:
            do {
                try db.executeUpdate("ALTER TABLE Favorites ADD photoReference TEXT", values: nil)
            } catch{
                print("Error updating database to version:\(version+1). Error: \(error.localizedDescription)")
                noError = false
            }
            updatedVersion += 1
        default:
            break
        }
        if(noError){
            updateDBVersionInTable(db: db)
        }
    }
    
    /**
     This function updates the version of the database in the table that stores the database's version.
     - parameter db: The database where the version should be updated.
     */
    fileprivate func updateDBVersionInTable(db: FMDatabase) {
        do {
            try db.executeUpdate("INSERT OR REPLACE INTO dbVersion (id, version) VALUES ('1',?)", values: [latestDBversion])
        } catch {
            print("Error updating database version in dbVersion table: \(error.localizedDescription)")
        }
    }
    
    /**
     This function gets all the favorite places saved in the database.
     
     - parameter completion: The callback called after retrieval of the favorite places.
     - parameter favorites: An array with all the favorite places saved in the database.
     */
    open func getFavoritePlaces(completion: @escaping (_ favorites: [PlaceModel]) -> Void){
        var favoritePlaces = [PlaceModel]()
        self.dbQueue?.inDatabase{ db in
            do {
                let haveFavoritesSaved: FMResultSet =  try db.executeQuery("SELECT * FROM Favorites", values: nil)
                while(haveFavoritesSaved.next()){
                    let retrievedId = haveFavoritesSaved.string(forColumn: "id")
                    let name = haveFavoritesSaved.string(forColumn: "name")
                    let rating = haveFavoritesSaved.double(forColumn: "rating")
                    let ratingsCount = haveFavoritesSaved.int(forColumn: "ratingsCount")
                    let photoReference = haveFavoritesSaved.string(forColumn: "photoReference")
                    
                    let newPlace = PlaceModel(newId: retrievedId,
                                              newName: name,
                                              newRating: rating,
                                              newRatingsCount: Int(ratingsCount),
                                              newIsFavorite: true,
                                              newPhotoReference: photoReference)
                    
                    favoritePlaces.append(newPlace)
                }
                completion(favoritePlaces)
            } catch {
                print("Error getting favorites:\(error)")
            }
        }
    }
    
    /**
     This function saves a place in the favorite places database.
     - parameter place: The place that should be saved to the favorites.
     */
    open func addToFavorites(place: PlaceModel) {
        self.dbQueue?.inDatabase{ db in
            do {
                try db.executeUpdate("INSERT INTO Favorites(id, name, rating, ratingsCount, photoReference) VALUES (?, ?, ?, ?, ?)", values: [place.id, place.name, place.ratings, place.ratingsCount, place.photoReference])
            } catch {
                print("Error while saving movie: \(error.localizedDescription)")
            }
        }
    }
    
    /**
     This function removes a place from the favorite places database.
     - parameter place: The place that should be removed from the favorites.
     */
    open func removeFromFavorites(place: PlaceModel) {
        self.dbQueue?.inDatabase{db in
            do{
                try db.executeUpdate("DELETE FROM Favorites WHERE id = ?", values: [place.id])
                print("Succesfully removed \(place.name) from favorites")
            }catch{
                print("Error removing \(place.name) from favorites: \(error.localizedDescription)")
            }
        }
    }
    
    /**
     This function verify if a place is saved in the favorites database.
     - parameter placeID: The place id of the place that should be verified.
     - Returns: A boolean indicating if the place is saved in the favorites database.
     */
    open func verifyIfIsFavorite(placeID: String) -> Bool{
        var isFavorite: Bool = false
        self.dbQueue?.inDatabase { db in
            do{
                let verifyFavorite = try db.executeQuery("SELECT * FROM Favorites WHERE id = ?", values: [placeID])
                if(verifyFavorite.next()){
                    isFavorite = true
                }
            } catch {
                print("Error verifying if place with id \(placeID) is in the favorites:\n\(error.localizedDescription)")
            }
        }
        return isFavorite
    }
}
