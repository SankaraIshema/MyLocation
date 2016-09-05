//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by BT-Training on 05/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

protocol CategoryPickerViewControllerDelegate : class {
    func categoryPickerViewController(controller : CategoryPickerViewController, didSelectCategory : String)
}

class CategoryPickerViewController: UITableViewController {
    
    let categories = ["No Category", "Bar", "Restaurant", "Clubs", "PokeStop", "WhoreHouse"]
    var selectedCategoryName = ""
    var selectedIndexPath : NSIndexPath?
    weak var categoryPickerViewControllerDelegate : CategoryPickerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        updateSelectedIndexPath()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSelectedIndexPath () {
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
            }
        }
    }

    
}

extension CategoryPickerViewController {
    
    // MARK: - Table view data source
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath)
        
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if indexPath == selectedIndexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
            
        }
        
        return cell
    }
    
}

extension CategoryPickerViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath != selectedIndexPath {
            let oldSelection = self.selectedIndexPath
            
            self.selectedIndexPath = indexPath
            selectedCategoryName = categories[indexPath.row]
            
            var toUpdate = [indexPath]
            if let oldSelection = oldSelection {
                toUpdate.insert(oldSelection, atIndex: 0)
            }
            tableView.reloadRowsAtIndexPaths(toUpdate, withRowAnimation: .Fade)
            
            if let delegate = categoryPickerViewControllerDelegate {
                delegate.categoryPickerViewController(self, didSelectCategory : self.selectedCategoryName)
            }
            
        } else {
            
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
    }
}


































