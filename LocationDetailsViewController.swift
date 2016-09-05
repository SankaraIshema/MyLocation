//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by BT-Training on 02/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import CoreLocation

class LocationDetailsViewController: UITableViewController {

    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var lobgitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark : CLPlacemark?
    let dateFormatter : NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var category : String = "No Category"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = ""
        categoryLabel.text = ""
        latitudeLabel.text = String(format : "%.8f", coordinate.latitude)
        lobgitudeLabel.text = String(format : "%.8f", coordinate.longitude)
        categoryLabel.text = category
        
        if let placemark = self.placemark {
            addressLabel.text = StringFromPlacemark(placemark)
                        
        } else {
            
            addressLabel.text = "No address found"
        }
        
        dateLabel.text = formatDate(NSDate())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelTapped(sender: AnyObject) {
    }
    @IBAction func doneTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
    
    func formatDate(date : NSDate) -> String {
        
        return dateFormatter.stringFromDate(date)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CategorySegue" {
            if let categoryPickerViewController = segue.destinationViewController as? CategoryPickerViewController {
                categoryPickerViewController.selectedCategoryName = category
                
                
                //categoryPickerViewController.categoryPickerViewControllerDelegate = self
                
            }
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(segue : UIStoryboardSegue) {
        print("Ca maaaaaarche")
        if segue.identifier == "pickedCategory" {
            if let controller = segue.sourceViewController as? CategoryPickerViewController {
                category = controller.selectedCategoryName
                categoryLabel.text = category
            }
            
        }
    }
    
}

extension LocationDetailsViewController : CategoryPickerViewControllerDelegate {
    
    func categoryPickerViewController(controller: CategoryPickerViewController, didSelectCategory category: String){
        self.category = category
        self.categoryLabel.text = category
        self.navigationController?.popViewControllerAnimated(true)
    
    }
}





















