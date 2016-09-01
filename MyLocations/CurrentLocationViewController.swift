//
//  FirstViewController.swift
//  MyLocations
//
//  Created by BT-Training on 01/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func buttonTapped(sender: AnyObject) {
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
            
        case .NotDetermined  :  locationManager.requestWhenInUseAuthorization()
        case .Denied, .Restricted : showLocationServicesDeniedAlert()
        default : break
            
        }
        
    
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: "Location servives disabled", message: "Please enable location services for this app", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .Default , handler :nil)
        alert.addAction(okAction)
        presentViewController(alert, animated : true, completion : nil)
    
    }
    


}

extension CurrentLocationViewController : CLLocationManagerDelegate{
    
    func locationManager (manager : CLLocationManager, didFailWithError error : NSError) {
        print("Did fail with error \(error)")
    }
    
    func locationManager (manager : CLLocationManager, didUpdateLocations locations : [CLLocation]) {
        print("Did update locations :  \(locations.last!)")
    }
    
}

