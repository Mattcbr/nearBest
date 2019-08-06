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
    
    fileprivate func updateDBVersionInTable(db: FMDatabase) {
        do {
            try db.executeUpdate("INSERT OR REPLACE INTO dbVersion (id, version) VALUES ('1',?)", values: [latestDBversion])
        } catch {
            print("Error updating database version in dbVersion table: \(error.localizedDescription)")
        }
    }
    
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
                
            }
        }
    }
    
    open func addToFavorites(place: PlaceModel) {
        self.dbQueue?.inDatabase{ db in
            do {
                try db.executeUpdate("INSERT INTO Favorites(id, name, rating, ratingsCount, photoReference) VALUES (?, ?, ?, ?, ?)", values: [place.id, place.name, place.ratings, place.ratingsCount, place.photoReference])
            } catch {
                print("Error while saving movie: \(error.localizedDescription)")
            }
        }
    }
    
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
    
    open func getFavoritesQuantity() -> Int{
        var quantity = Int()
        self.dbQueue?.inDatabase { db in
            do {
                let favoritesCounter = try db.executeQuery("SELECT COUNT(*) FROM Favorites", values: nil)
                if (favoritesCounter.next()){
                    quantity = Int(favoritesCounter.int(forColumn: "COUNT(*)"))
                }
            } catch {
                print("Error getting quantity of Favorites:\(error.localizedDescription)")
            }
        }
        return quantity
    }
    
    open func verifyIfIsFavorite(placeID: String) -> Bool{
        var isFavorite: Bool = false
        self.dbQueue?.inDatabase { db in
            do{
                let verifyFavorite = try db.executeQuery("SELECT * FROM Favorites WHERE id = ?", values: [placeID])
                if(verifyFavorite.next()){
                    isFavorite = true
                }
            } catch {
                
            }
        }
        return isFavorite
    }
}
