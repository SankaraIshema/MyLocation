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
    var location : CLLocation?
    var updatingLocation = false
    var lastLocationError : NSError?
    
    let geocoder = CLGeocoder()
    var placemark : CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError : NSError?
    
    var timer: NSTimer?
    
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
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            startLocationManager()
        }
    
        updateLabels()
        configureGetButton ()
    
        
    }
    
    func showLocationServicesDeniedAlert() {
        
        let alert = UIAlertController(title: "Location servives disabled", message: "Please enable location services for this app", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .Default , handler :nil)
        alert.addAction(okAction)
        presentViewController(alert, animated : true, completion : nil)
    
    }
    
    func configureGetButton() {
        
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
        } else {
            getButton.setTitle("Get my location", forState: .Normal)
        }
    }
    
    func StringFromPlacemark (placemark : CLPlacemark) -> String {
        
        var line1 = " "
        if let streetName = placemark.thoroughfare {
            line1 += streetName + " "
        }
        if let number = placemark.subThoroughfare {
            line1 += number
        }
        
        var line2 = " "
        if let postalCode = placemark.postalCode {
            line2 += postalCode
        }
        if let city = placemark.locality {
            line2 += city
        }
        
        return line1 + " " + line2
        
    }

    
    func updateLabels () {
        
        if let location = self.location {
            latitudeLabel.text = String (format : "%.8f" , location.coordinate.latitude)
            longitudeLabel.text = String(format : "%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = " "
            
            if let placemark = self.placemark {
                
                addressLabel.text = StringFromPlacemark(placemark)
                
            }else if performingReverseGeocoding {
                addressLabel.text = "Searching for address..."
                
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error finding adress."
                
            } else {
                addressLabel.text = " Adress not found."
            }
            
        } else {
            latitudeLabel.text = " "
            longitudeLabel.text = " "
            messageLabel.text = "Tap button to get location"
            addressLabel.text = " "
            tagButton.hidden = true
        
            let statusMessage : String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                        statusMessage = "Location services disabled"
                }
                else {
                    statusMessage = "Error getting location"
                }
            }
            else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Searching..."
    
            }
            else {
                statusMessage = "Tab 'Get My Location' to get started"
            }
        
            messageLabel.text = statusMessage
        }
    }
        
    func stopLocationManager () {
        if  updatingLocation {
            if let timer = self.timer{
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
        }
    }
        
    func startLocationManager () {
        if CLLocationManager.locationServicesEnabled() {
                
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
        
    }
        func didTimeOut() {
            print("Time Out")
            if location == nil {
                stopLocationManager()
                lastLocationError = NSError(domain: "My location", code: 1, userInfo: nil)
                updateLabels()
                configureGetButton()
            }
        }
        
}
    


extension CurrentLocationViewController : CLLocationManagerDelegate{

    
    func locationManager (manager : CLLocationManager, didFailWithError error : NSError) {
        lastLocationError = error
        print("Did fail with error \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
    }
    
    func locationManager (manager : CLLocationManager, didUpdateLocations locations : [CLLocation]) {
        
        
        let newLocation = locations.last!
        lastLocationError = nil
        print("Did update locations :  \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = self.location {
            
            distance = newLocation.distanceFromLocation(location)
        }



        
        if location == nil || newLocation.horizontalAccuracy <= location!.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("there")
                stopLocationManager()
                
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding {
                print("geocoding")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation)
                {
                    placemarks, error in print("Found placemarks : \(placemarks), error : \(error)")
                    
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks where !p.isEmpty {
                        self.placemark = p.last!
                    
                    } else {
                        
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                    self.configureGetButton()
                }
    
                
            }
        

        
        }
        
        else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                print("Force done")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
     }
    
    
  }
    
}

