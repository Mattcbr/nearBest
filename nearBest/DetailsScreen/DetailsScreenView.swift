//
//  DetailsScreenViewController.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import UIKit

private let reuseIdentifier = "detailsCell"

class DetailsScreenView: UICollectionViewController, DetailsCellDelegate {
    
    public var screenType: String?
    public var lat: Double?
    public var long: Double?
    public var favorites: [PlaceModel]?
    public var controller: DetailsScreenController?
    fileprivate var isLoadingData: Bool = true
    
    var delegate:DetailsScreenControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let newDelegate = delegate {
            if let favoritePlaces = favorites {
                controller = DetailsScreenController.init(view: self, delegate: newDelegate, favorites: favoritePlaces)
            } else {
                controller = DetailsScreenController.init(view: self, delegate: newDelegate, favorites: nil)
            }
        }
    }
    
    public func didLoadPlaces(){
        self.collectionView.reloadData()
        isLoadingData = false
    }
    
    public func setupNavigation(withTitle title:String){
        self.navigationItem.title = title
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller?.placesArray.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? DetailsCell else {
            fatalError("Not a details cell")
        }
    
        let placeToDisplay = controller?.placesArray[indexPath.row]
        if let place = placeToDisplay {
            cell.setupForPlace(place: place)
            
            if (!place.isThumbnailLoaded){
                controller?.loadImage(forPlace: place, completion: { (newThumbnail) in
                    place.thumbnail = newThumbnail
                    place.isThumbnailLoaded = true
                    cell.placeThumbnail.image = newThumbnail
                    cell.setupForPlace(place: place)
                    if(self.controller?.placesArray.first == place && self.favorites == nil){
                        cell.isBestAround()
                    }
                })
            }
            
            if(controller?.placesArray.first == place && favorites == nil){
                cell.isBestAround()
            }
        }
        
        cell.delegate = self
        return cell
    }

    //MARK: Infinite Scroll
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        let diff = scrollContentSizeHeight - scrollOffset - scrollViewHeight    //This detects if the scroll is near the botom of the scroll view
        
        if (diff<40 && !isLoadingData)    //If the scroll is near the bottom, and there is no data being loaded, make a new request.
        {
            controller?.requestMorePlaces()
            isLoadingData = true
        }
    }
    
    //MARK: Details Cell Delegate
    
    func didPressFavoriteButton(cell: DetailsCell) {
        let position = collectionView.indexPath(for: cell)?.row
        if let placePosition = position{
            controller?.didPressFavorite(forPlaceAt: placePosition)
        }
    }
    
    func showRemoveFromFavoritesAlert(forPlace place: PlaceModel){
        
        let alertPlaceName = place.name ?? "this place"
        let alert = UIAlertController(title: "Are you sure?",
                                      message: "Do you really want to delete \(alertPlaceName) from your favorites?",
                                      preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.controller?.removeFromFavorites(place: place)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func didChangeFavoriteStatus(forElementAt index: Int){
        let indexPathToReload = IndexPath(row: index, section: 0)
        self.collectionView.reloadItems(at: [indexPathToReload])
    }
    
    func showErrorAlert(error: Error){
        let alert = UIAlertController(title: "Loading Failure", message: "\(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}


extension DetailsScreenView: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 200);
    }
}
