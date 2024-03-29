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
    
    override func viewWillAppear(_ animated: Bool) {
        removeLoadingIndicators()
    }
    
    //MARK: - Location Settings
    
    /**
     This function shows an error message explaining that the app needs location permission. It also gives the user a button to go to the app's settings and change that permission.
     */
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
    
    /**
     This function sets up the buttons, hides unneccessary buttons and disables all the buttons.
     
     This function should be called before the first API request and DB load.
     */
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
    
    /**
     This function is called whenever a button is pressed and sets the "selectedButtonIdentifier" variable.
     - Parameter sender: The pressed button.
     */
    @objc func didPressButton(sender: UIButton){
        switch sender {
        case favoritesButton:
            selectedButtonIdentifier = "favorites"
        case restaurantsButton:
            selectedButtonIdentifier = "restaurant"
        case mallsButton:
            selectedButtonIdentifier = "Shopping Mall"
        case museumsButton:
            selectedButtonIdentifier = "museum"
        case hospitalsButton:
            selectedButtonIdentifier = "hospital"
        default:
            print("Pressed button not recognized")
        }
        self.performSegue(withIdentifier: "showPlacesSegue", sender: self)
    }
    
    /**
     This function removes the loading indicator, enables all the buttons, and verifies if the "Favorites" button should be shown.
     */
    func removeLoadingIndicators(){
        loadingIndicator.stopAnimating()
        
        favoritesButton.isEnabled = true
        restaurantsButton.isEnabled = true
        mallsButton.isEnabled = true
        museumsButton.isEnabled = true
        hospitalsButton.isEnabled = true
        
        if let count = self.controller?.favoritePlaces?.count {
            favoritesButton.isHidden = !(count > 0)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showPlacesSegue"){
            let destination = segue.destination as! DetailsScreenView
            destination.screenType = selectedButtonIdentifier
            destination.long = controller?.long
            destination.lat = controller?.lat
            destination.delegate = self.controller
            
            let backButton = UIBarButtonItem()
            backButton.title = "Home"
            navigationItem.backBarButtonItem = backButton
            
            if selectedButtonIdentifier == "favorites"{
                destination.favorites = controller?.favoritePlaces
            }
        }
    }
}
