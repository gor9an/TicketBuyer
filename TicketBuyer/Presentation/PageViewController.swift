//
//  ViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 18.10.2023.
//

import UIKit
import Firebase

class PageViewController: UIViewController, AlertPresenterDelegate {
    
    @IBOutlet weak var generalImage: UIImageView!
    
    //Main Stack View Images
    @IBOutlet weak var firstMainStackViewButton: UIButton!
    @IBOutlet weak var secondMainStackViewButton: UIButton!
    @IBOutlet weak var thirdMainStackViewButton: UIButton!
    
    @IBOutlet weak var firstSecScrollVImage: UIImageView!
    @IBOutlet weak var secondSecScrollVImage: UIImageView!
    @IBOutlet weak var thirdSecScrollVImage: UIImageView!
    
    
    
    @IBOutlet weak var forAllTimeScrollView: UIScrollView!
    @IBOutlet weak var actualScrollView: UIScrollView!
    
    @IBOutlet weak var adminButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                self.showModalAuth()
            } else {
                self.checkAdmin()
            }
        }
        
        //Scroll View settings
        forAllTimeScrollView.layer.cornerRadius = 30
        actualScrollView.layer.cornerRadius = 30
        
        //Images settings
        firstMainStackViewButton.layer.cornerRadius = 30
        secondMainStackViewButton.layer.cornerRadius = 30
        thirdMainStackViewButton.layer.cornerRadius = 30
        
        generalImage.layer.cornerRadius = 30
        
        firstSecScrollVImage.layer.cornerRadius = 30
        secondSecScrollVImage.layer.cornerRadius = 30
        thirdSecScrollVImage.layer.cornerRadius = 30
        adminButton.layer.cornerRadius = 20
        
    }
    
//    MARK: - Private funcions
    private func checkAdmin() {
        if let currentUser = Auth.auth().currentUser {
            let expectedUid = "OfRBiv5uN8W6SjCMbqrPSSxOpQY2"
            
            if currentUser.uid == expectedUid {
                adminButton.isHidden = false
            } else {
                adminButton.isHidden = true
            }
        }
    }
    
//    MARK: - IBActions
    @IBAction func exitButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }

    @IBAction func movieButtonTapped(_ sender: Any) {
    }
    
    private func showModalAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "AuthController") as! AuthViewController
        newVC.modalPresentationStyle = .fullScreen
        
        self.present(newVC, animated: true, completion: nil)
    }
    
//    MARK: AlertPresenterDelegate
    func didReceiveAlert() { }
}

