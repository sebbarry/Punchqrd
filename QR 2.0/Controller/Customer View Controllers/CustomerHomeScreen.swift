//
//  CustomerHomeScreen.swift
//  QR 2.0
//
//  Created by Sebastian Barry on 5/25/20.
//  Copyright © 2020 Sebastian Barry. All rights reserved.

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import GooglePlaces
import GoogleMaps




class CustomerHomeScreen : UIViewController{
    
    //refresher variable
    var refresher : UIRefreshControl!
    //the created table view in the home screen
    @IBOutlet weak var BusinessList: UITableView!
    //the array created to hold business names and points the user has added to display to the tableview
    var BusinessNamesArray : [BusinessName] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BusinessList.delegate = self
        // Remove the background color.
        navigationController?.navigationBar.setBackgroundImage(UIColor.clear.as1ptImage(), for: .default)
        // Set the shadow color.
        navigationController?.navigationBar.shadowImage = UIColor.clear.as1ptImage()
        refreshTableView()
        
        
    }
    
    
    //what will appear in the view before it loads onto the screen
    override func viewWillAppear(_ animated: Bool) {
        
        self.BusinessList.backgroundColor = .white
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = false
        
        showList()
        
    }
    
    
    
    
    //functuon to create a business list and show it on the screen
    func showList() {
        createBusinessList()
        BusinessList.dataSource = self
        BusinessList.register(UINib(nibName: GlobalVariables.UserIDs.CustomerNibCell, bundle: nil), forCellReuseIdentifier: GlobalVariables.UserIDs.CustomerTableViewCellID)
        BusinessList.rowHeight = 100
    }
    
    //function to refresh the table view
    func refreshTableView() {
        //this is the refresh list variables to enable a refresh for the UITableView
        self.refresher = UIRefreshControl()
        self.BusinessList.reloadData()
        self.refresher.addTarget(self, action: #selector(CustomerHomeScreen.refresh), for: UIControl.Event.valueChanged)
        self.BusinessList.addSubview(self.refresher)
        self.refresher.backgroundColor = .white
        
    }
    
    @objc func refresh()
    {
        refreshData()
        self.BusinessList.reloadData()
        self.refresher.endRefreshing()
        
    }
    
    //function to refresh the data on the page
    func refreshData() {
        self.BusinessList.reloadData()
        DispatchQueue.main.async { self.BusinessList.reloadData() }
        createBusinessList()
        BusinessList.dataSource = self
        BusinessList.register(UINib(nibName: GlobalVariables.UserIDs.CustomerNibCell, bundle: nil), forCellReuseIdentifier: GlobalVariables.UserIDs.CustomerTableViewCellID)
        self.refresher.endRefreshing()
    }
    
    
    
    
    
    //create a new list of business NAMES added (this list is according to the businesses the user added
    func createBusinessList() {
        BusinessNamesArray = []
        //access the database
        let db = Firestore.firestore()
        //specify the correct path to the collection set
        db.collection(GlobalVariables.UserIDs.CollectionTitle).document((Auth.auth().currentUser?.email)!).collection(GlobalVariables.UserIDs.CustomerBusinessCollection).getDocuments { (Businesses, error) in
            if let error = error {print(error)}
                
            else {
                for businessNames in Businesses!.documents {
                    //this is where you can add all the businesses to the tableview
                    let newBusinessAdded = BusinessName(inputName: businessNames.documentID, pointsAdded: businessNames.get(GlobalVariables.UserIDs.PointsString) as? Float ?? 0, redemptionCode: businessNames.get(GlobalVariables.UserIDs.RedemptionNumberString) as? Int ?? 0)
                    //add a new business to the array
                    print("\(newBusinessAdded.points) new points added")
                    
                    self.BusinessNamesArray.append(newBusinessAdded)
                    //setup this when reloading the data
                    print(newBusinessAdded.name)
                }
                self.BusinessList.reloadData()
            }
        }
    }
    
    
    
    @IBAction func viewQRButton(_ sender: UIButton) {
        
        
    }
    
    
    @IBAction func searchBusinessButton(_ sender: UIBarButtonItem) {
        
        
    }
    
    
    func createBottomAlert(title : String?, message : String?, valueRemove : Int, path : IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            GlobalFunctions.deleteBusinessFromCustomerCollection(nameOfFile: self.BusinessNamesArray[valueRemove].name)
            self.BusinessNamesArray.remove(at: valueRemove)
            self.BusinessList.deleteRows(at: [path], with: .fade)
            //insert the function to delete a piece of data from the collection
            self.BusinessList.reloadData()
            alert.dismiss(animated: true, completion: nil)
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        
        self.present(alert, animated: true)
    }
    
    //logout alert
    func logoutAlert(title : String?, message : String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                //send the user back to the homescreen
                self.navigationController?.popToRootViewController(animated: true)
                print("Logged out the user")
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        
        self.present(alert, animated: true)
    }
    
    
    
    //button action to logout the user
    @IBAction func LogoutButton(_ sender: UIBarButtonItem) {
        logoutAlert(title: "Logout?", message: nil)
    }
    
    
}

//extension for the uitable view data
extension CustomerHomeScreen: UITableViewDataSource, UITableViewDelegate {
    
    //how many cells should be present
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //this should be the actual lenght of the array
        return BusinessNamesArray.count
    }
    
    //what will be show in each cell in the table view? : (name, points, progressbar updates, etc) Return the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BusinessList.dequeueReusableCell(withIdentifier: GlobalVariables.UserIDs.CustomerTableViewCellID, for: indexPath) as! BusinessForCustomerCell
        let colorHolder : [UIColor] = [.blue, .green, .yellow, .cyan, .systemPurple, .magenta]
        let randomColor = Int.random(in: 0...5)
        cell.PointsProgressBar.trackTintColor = UIColor.lightGray.withAlphaComponent(0.20)
        cell.PointsProgressBar.progressTintColor = colorHolder[randomColor]
        //background color on cell select (not gray)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        
        cell.CheckMarkImage.isHidden = true
        cell.BusinessName.text = self.BusinessNamesArray[indexPath.row].name
        cell.PointsProgressBar.setProgress((self.BusinessNamesArray[indexPath.row].points/10), animated: true)
        print(self.BusinessNamesArray[indexPath.row].points/10)
        cell.Points.text = String("\(Int(self.BusinessNamesArray[indexPath.row].points)):10")
        if cell.PointsProgressBar.progress.isEqual(to: 1) {
            cell.CheckMarkImage.isHidden = false
            cell.Points.isHidden = true
        }
        if cell.PointsProgressBar.progress.isEqual(to: 0) {
            cell.Points.isHidden = false
        }
        return cell
    }
    
    
    //disable full swipe accross cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            self.createBottomAlert(title: "Remove this Business?", message: "All points will be lost", valueRemove: indexPath.row, path: indexPath)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }
    
    
}

extension UIColor {
    
    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
