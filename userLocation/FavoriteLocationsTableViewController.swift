 //
//  favoriteLocationsTableViewController.swift
//  userLocation
//
//  Created by Lisa H Steele on 1/10/17.
//  Copyright © 2017 Lisa Steele. All rights reserved.
//

import UIKit

let favoriteLocationKey = "NewFavoriteLocation"

class FavoriteLocationsTableViewController: UITableViewController {

    var listOfFavorites: [SavedFavorites] = []
    var components = ""
    var updatedListOfFavorites = ""
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        let favoriteLocations =  defaults.string(forKey: favoriteLocationKey)
        
        
        if let components = favoriteLocations?.components(separatedBy: "+") {
            
            for component in components {
                let locationComponents = component.components(separatedBy: ";")
                
                let singleLocation = (lat: locationComponents[0], long: locationComponents[1], location: locationComponents[2])
                
                addFavorite(tuple: singleLocation)
            }
            
            //Zephyr.sync(keys: favoriteLocationKey)
        }
        
        

        tableView.reloadData()
        
        let moveButton = UIBarButtonItem(title: "Re-order", style: .plain, target: self, action: #selector(FavoriteLocationsTableViewController.toggleEdit))
        navigationItem.leftBarButtonItem = moveButton
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(FavoriteLocationsTableViewController.addNewFavorite))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func addFavorite(tuple: (lat: String, long:String, location: String)) {
        
        let newLatCoord = tuple.lat
        let newLongCoord = tuple.long
        let newLocation = tuple.location
        
        let newFavourite = SavedFavorites(latCoord: newLatCoord, longCoord: newLongCoord, location: newLocation)
        
        //Zephyr.sync(keys: "NewFavoriteLocation")
        self.listOfFavorites.append(newFavourite)
      
        let newIndexPath = IndexPath(row: self.listOfFavorites.count - 1, section: 0)
        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
        
    }
    
    
    func resaveListOfFavorites() {
        //in this function, I need to convert the listOfFavorites back to a single string.
        //assign this to the variable updatedListOfFavorites, and this will be saved to userDefaults.
        
        //print ("ListOfFavorites \(listOfFavorites)")
        
        var i = 0
        
        var updatedListOfFavorites = ""
        
        for favorite in listOfFavorites {
            
            //put all three constants in an if to safely unwrap. need to define updatedSingleLocation before the if as an empty string. Then reassign in the if.
            
            var updatedSingleLocation = ""
            
            if let updatedLatCoord = favorite.latCoord {
                if let updatedLongCoord = favorite.longCoord {
                    if let updatedLocation = favorite.location {
                        updatedSingleLocation = "\(updatedLatCoord);\(updatedLongCoord);\(updatedLocation)"
                    }
                }
            }
            
            //print ("UpdatedSingleLocation \(updatedSingleLocation)")
            
            //do this if in two stages: unwrap listOfFavorites.last first, then compare the result of unwrapping with updatedSingleLocation.
            
            if i != listOfFavorites.count - 1 {
                updatedSingleLocation.append("+")
            }
            
            updatedListOfFavorites.append(updatedSingleLocation)
            
            i += 1
        }
        
        let defaults = UserDefaults.standard
        defaults.set(updatedListOfFavorites, forKey: favoriteLocationKey)
        
        //Zephyr.sync(keys: favoriteLocationKey)
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let favorite = self.listOfFavorites[indexPath.row]
    
        if let locationName = favorite.location {
            
            cell.textLabel?.text = locationName
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.listOfFavorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            resaveListOfFavorites()
        }
        tableView.reloadData()
    }
    
    

    
    func addNewFavorite(_ sender: Any?) {
        performSegue(withIdentifier: "AddNewFavoriteSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddNewFavoriteSegue") {
            _ = segue.destination as! ViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfFavorites.count
    }
    
    func toggleEdit() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let favoriteMoving = listOfFavorites.remove(at: fromIndexPath.row)
        listOfFavorites.insert(favoriteMoving, at: to.row)
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .none
        } else {
            return .delete
        }
    }
    
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
