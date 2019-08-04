//
//  DetailsScreenViewController.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import UIKit

private let reuseIdentifier = "detailsCell"

class DetailsScreenView: UICollectionViewController {
    
    public var screenType: String?
    public var lat: Double?
    public var long: Double?
    private var controller: DetailsScreenController?
    private var isLoadingData: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller = DetailsScreenController.init(view: self)
    }
    
    public func didLoadPlaces(){
        self.collectionView.reloadData()
        isLoadingData = false
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
            if(controller?.placesArray.first == place){
                cell.isBestAround()
            }
        }
    
        return cell
    }

    //MARK: Infinite Scroll
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        let diff = scrollContentSizeHeight - scrollOffset - scrollViewHeight    //This detects if the scroll is near the botom of the scroll view
        
        if (diff<30 && !isLoadingData)    //If the scroll is near the bottom, and there is no data being loaded, make a new request.
        {
            controller?.requestMorePlaces()
            isLoadingData = true
        }
    }
    
}
