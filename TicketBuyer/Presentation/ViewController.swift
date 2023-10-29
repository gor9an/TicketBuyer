//
//  ViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 18.10.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var generalImage: UIImageView!
    //Main Stack View Images
    @IBOutlet weak var firstMainStackViewImage: UIImageView!
    @IBOutlet weak var secondMainStackViewImage: UIImageView!
    @IBOutlet weak var thirdMainStackViewImage: UIImageView!
    
    @IBOutlet weak var firstSecScrollVImage: UIImageView!
    @IBOutlet weak var secondSecScrollVImage: UIImageView!
    @IBOutlet weak var thirdSecScrollVImage: UIImageView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var forAllTimeScrollView: UIScrollView!
    @IBOutlet weak var actualScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        loginButton.layer.cornerRadius = 15

    }
    
}

