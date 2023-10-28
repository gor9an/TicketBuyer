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
    
    @IBOutlet weak var forAllTimeScrollView: UIScrollView!
    @IBOutlet weak var actualScrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //Scroll View settings
        actualScrollView.layer.masksToBounds = true // даём разрешение на рисование рамки

        actualScrollView.layer.cornerRadius = 30 // радиус скругления углов рамки
        actualScrollView.layer.borderColor = UIColor.black.cgColor
        actualScrollView.layer.borderWidth = 4 // толщина рамки
        
        forAllTimeScrollView.layer.masksToBounds = true
        
        forAllTimeScrollView.layer.cornerRadius = 30 // радиус скругления углов рамки
        forAllTimeScrollView.layer.borderColor = UIColor.black.cgColor
        forAllTimeScrollView.layer.borderWidth = 4 // толщина рамки
        
        //Images settings
        firstMainStackViewImage.layer.cornerRadius = 30
        secondMainStackViewImage.layer.cornerRadius = 30
        thirdMainStackViewImage.layer.cornerRadius = 30
        
        generalImage.layer.cornerRadius = 50


    }


}

