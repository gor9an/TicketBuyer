//
//  ViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 18.10.2023.
//

import UIKit
import FirebaseAuth

class PageViewController: UIViewController {
    
    @IBOutlet weak var generalImage: UIImageView!
    
    //Main Stack View Images
    @IBOutlet weak var firstMainStackViewImage: UIImageView!
    @IBOutlet weak var secondMainStackViewImage: UIImageView!
    @IBOutlet weak var thirdMainStackViewImage: UIImageView!
    
    @IBOutlet weak var firstSecScrollVImage: UIImageView!
    @IBOutlet weak var secondSecScrollVImage: UIImageView!
    @IBOutlet weak var thirdSecScrollVImage: UIImageView!
    
    
    
    @IBOutlet weak var forAllTimeScrollView: UIScrollView!
    @IBOutlet weak var actualScrollView: UIScrollView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                self.showModalAuth()
            }
        }
        
        //Scroll View settings
        forAllTimeScrollView.layer.cornerRadius = 30
        actualScrollView.layer.cornerRadius = 30
        
        //Images settings
        firstMainStackViewImage.layer.cornerRadius = 30
        secondMainStackViewImage.layer.cornerRadius = 30
        thirdMainStackViewImage.layer.cornerRadius = 30
        
        generalImage.layer.cornerRadius = 30
        
        firstSecScrollVImage.layer.cornerRadius = 30
        secondSecScrollVImage.layer.cornerRadius = 30
        thirdSecScrollVImage.layer.cornerRadius = 30
        
    }
    
    func showModalAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "AuthController") as! AuthViewController
        
        self.present(newVC, animated: true, completion: nil)
    }
}

