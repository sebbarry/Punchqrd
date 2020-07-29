//
//  OwnerHomeScreen.swift
//  FizzyPoints
//
//  Created by Sebastian Barry on 5/26/20.
//  Copyright © 2020 Sebastian Barry. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import AVKit
import StoreKit
import Lottie


class OwnerHomeScreen : UIViewController, SKPaymentTransactionObserver {
    
    let animationView1 = AnimationView()
    let productID = "com.SebastianBarry.FizzyPoints.BusinessPack"

    @IBOutlet weak var RemoveEmployeeButton: UIButton!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var AddEmployeeButton: UIButton!
    @IBOutlet weak var ScanDataButton: UIButton!
    
    private lazy var animationView2: AnimationView = {
         let view = AnimationView()
         return view
       }()
    
    //MARK:- View functions
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        navigationController?.navigationBar.titleTextAttributes =
                    [NSAttributedString.Key.foregroundColor: UIColor.systemPurple,
                    NSAttributedString.Key.font: UIFont(name: "Poppins", size: 25)!]
               
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .systemPurple
        navigationItem.title = String(describing: "Owner Portal")
        
        setupAnimation2(parentView: self.view, animationView: animationView2, animationName: "SippingCoffee")
        
        //check if the user is subscribed **
        SKPaymentQueue.default().add(self)
        let db = Firestore.firestore()
        let OwnerCollection = db.collection(GlobalVariables.UserIDs.CollectionTitle).document((Auth.auth().currentUser?.email)!)
        OwnerCollection.getDocument { (doc, error) in
            if let doc = doc, doc.exists {
                let registerValue = doc.get(GlobalVariables.UserIDs.OwnerRegisteredTitle) as! String
                if registerValue == "false" {
                    SKPaymentQueue.default().add(self)
                    print(registerValue)
                    self.addLoadingView()
                    self.setupPremiumPurchase()
                }
            }
        }
        
           
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIColor.clear.as1ptImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIColor.clear.as1ptImage()
        self.navigationController?.navigationBar.isHidden = false
        GlobalFunctions.setButtonRadius(button: self.AddEmployeeButton)
        GlobalFunctions.setButtonRadius(button: self.RemoveEmployeeButton)
        GlobalFunctions.setButtonRadius(button: self.ScanDataButton)
        navigationController?.navigationBar.titleTextAttributes =
                           [NSAttributedString.Key.foregroundColor: UIColor.systemPurple,
                           NSAttributedString.Key.font: UIFont(name: "Poppins", size: 25)!]
                      
               navigationController?.navigationBar.barTintColor = .white
               navigationController?.navigationBar.tintColor = .systemPurple
               navigationItem.title = String(describing: "Owner Portal")
               
               setupAnimation2(parentView: self.view, animationView: animationView2, animationName: "SippingCoffee")
    }
    
    //MARK:- Actions
    @IBAction func AddEmployeeAction(_ sender: UIButton) {
        
    }
    
    @IBAction func RemoveEmployeeAction(_ sender: UIButton) {
        
    }
    
    
    @IBAction func ScanDataAction(_ sender: UIButton) {
        
    }
    
    
    @IBAction func LogoutButton(_ sender: UIBarButtonItem) {
        logoutAlert(title: "Logout?", message: nil)
    }
    
    //MARK:- Alerts
    func logoutAlert(title : String?, message : String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                //send the user back to the homescreen
                self.navigationController?.popToRootViewController(animated: false)
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
    
    
    
    //MARK:- Purchase Setup. Check if the purhchase by the owner was made. If so, he can login. This stops subscription, registering, unsubscribing, but still being able to login.
    func setupPremiumPurchase() {
        self.addLoadingView()
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
            print("Checking different Queue items")
            
            
        } else {
            self.removeLoadingView()
            print("Cannot make payments")
        }
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        print("Function called")
        for transactions in transactions {
            
            if transactions.transactionState == .purchased {
                //user payment was successful
                //check if the user is registered in the database
                let db = Firestore.firestore()
                let OwnerCollection = db.collection(GlobalVariables.UserIDs.CollectionTitle).document((Auth.auth().currentUser?.email)!)
                OwnerCollection.getDocument { (doc, error) in
                    if let doc = doc, doc.exists {
                        OwnerCollection.updateData([GlobalVariables.UserIDs.OwnerRegisteredTitle : "true"])
                        
                    }
                }
                print("transaction was successful")
                self.removeLoadingView()
                SKPaymentQueue.default().finishTransaction(transactions)
                
            }
                
            else if transactions.transactionState == .failed {
                
                
                if let error = transactions.error {
                    print(error.localizedDescription)
                    self.removeLoadingView()
                    SKPaymentQueue.default().finishTransaction(transactions)
                    self.navigationController?.popViewController(animated: false)
                }
                else if transactions.transactionState == .restored {
                    print("That")
                    self.removeLoadingView()
                    SKPaymentQueue.default().finishTransaction(transactions)
                }
            }
            
        }
        
    }
    
    
    //MARK: - Animations
    func addLoadingView() {
        self.setupAnimation()
    }
    
    
    func setupAnimation() {
        let animationNames : [String] = ["CroissantLoader", "BeerLoader", "PizzaLoader", "CoffeeLoader"]
        let randomNumber = Int.random(in: 0...3)
        self.animationView1.animation = Animation.named(animationNames[randomNumber])
        self.animationView1.frame.size.height = self.view.frame.height
        self.animationView1.frame.size.width = self.view.frame.width
        self.animationView1.contentMode = .center
        self.animationView1.backgroundColor = .white
        self.animationView1.play()
        self.animationView1.loopMode = .loop
        self.view.addSubview(self.animationView1)
        
    }
    
    func removeLoadingView() {
        self.animationView1.stop()
        self.animationView1.removeFromSuperview()
    }
    
    func setupAnimation2(parentView: UIView, animationView: AnimationView, animationName: String) {
        animationView.animation = Animation.named(animationName)
        animationView.frame = CGRect(x: 0, y: 0, width: parentView.frame.size.width/1.5, height: parentView.frame.size.width/1.5)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(animationView2)
        animationView.widthAnchor.constraint(equalToConstant: parentView.frame.size.width/2).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: parentView.frame.size.width/2).isActive = true
        animationView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: animationView.frame.size.height/5).isActive = true
        animationView.contentMode = .scaleAspectFit
        
        animationView.layer.cornerRadius = 30
        animationView.backgroundColor = .white
        animationView.play()
        animationView.loopMode = .loop
        
        parentView.sendSubviewToBack(animationView)
    }
    
    
    
    
    
    
}
