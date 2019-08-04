//
//  MainScreenViewController.swift
//  nearBest
//
//  Created by Matheus Queiroz on 8/3/19.
//  Copyright © 2019 mattcbr. All rights reserved.
//

import UIKit
import CoreLocation

class MainScreenView: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var restaurantsButton: UIButton!
    @IBOutlet weak var mallsButton: UIButton!
    @IBOutlet weak var museumsButton: UIButton!
    @IBOutlet weak var hospitalsButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var selectedButtonIdentifier: String?
    var controller: MainScreenController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller = MainScreenController(view: self)
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        setupButtons()
    }
    
    //MARK: - Location Settings
    
    func showLocationErrorMessage(){
        let locationErrorAlert = UIAlertController(title: "Location permission",
                                                   message: "In order to be used, this app needs the location permission. Please, go to settings and change that permission",
                                                   preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        locationErrorAlert.addAction(settingsAction)
        self.present(locationErrorAlert, animated: true, completion: nil)
    }
    
    //MARK: - Buttons Settings
    
    func setupButtons(){
        favoritesButton.addTarget(self, action: #selector(didPressButton(sender:)), for: .touchUpInside)
        restaurantsButton.addTarget(self, action: #selector(didPressButton(sender:)), for: .touchUpInside)
        mallsButton.addTarget(self, action: #selector(didPressButton(sender:)), for: .touchUpInside)
        museumsButton.addTarget(self, action: #selector(didPressButton(sender:)), for: .touchUpInside)
        hospitalsButton.addTarget(self, action: #selector(didPressButton(sender:)), for: .touchUpInside)
        
        favoritesButton.isHidden = true
        
        favoritesButton.isEnabled = false
        restaurantsButton.isEnabled = false
        mallsButton.isEnabled = false
        museumsButton.isEnabled = false
        hospitalsButton.isEnabled = false
    }
    
    @objc func didPressButton(sender: UIButton){
        switch sender {
        case favoritesButton:
            selectedButtonIdentifier = "favorites"
        case restaurantsButton:
            selectedButtonIdentifier = "restaurant"
        case mallsButton:
            selectedButtonIdentifier = "Mall"
        case museumsButton:
            selectedButtonIdentifier = "museum"
        case hospitalsButton:
            selectedButtonIdentifier = "hospital"
        default:
            print("Pressed button not recognized")
        }
        self.performSegue(withIdentifier: "showPlacesSegue", sender: self)
    }
    
    func removeLoadingIndicators(){
            loadingIndicator.stopAnimating()
            
            favoritesButton.isEnabled = true
            restaurantsButton.isEnabled = true
            mallsButton.isEnabled = true
            museumsButton.isEnabled = true
            hospitalsButton.isEnabled = true
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showPlacesSegue"){
            let destination = segue.destination as! DetailsScreenView
            destination.screenType = selectedButtonIdentifier
            destination.long = controller?.long
            destination.lat = controller?.lat
        }
    }
}
