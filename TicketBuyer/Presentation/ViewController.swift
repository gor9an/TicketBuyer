//
//  ViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 18.10.2023.
//

import UIKit

class ViewController: UIViewController, AlertPresenterDelegate {
    
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

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var usersGetSet: User = User()
    private var alertPresenter: AlertPresenterProtocol = AlertPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        alertPresenter.delegate = self
        
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
    
    // MARK: - Private functions
    @IBAction private func loginButtonClick(_ sender: Any) {
        for user in usersGetSet.users {
            if (user.username == loginTextField.text)
                && (user.password == passwordTextField.text) {
                let text = "Вы вошли под администратором"
                let viewModel = AlertModel(
                    title: "Успех",
                    message: text,
                    buttonText: "Продожить")
                alertPresenter.requestAlert(result: viewModel)
                
            } else { // 2
                let text = "Вы ввели неправильный логин или пароль"
                let viewModel = AlertModel(
                    title: "Неудача",
                    message: text,
                    buttonText: "Продожить")
                alertPresenter.requestAlert(result: viewModel)
            }
                
        }
    }
    
    // MARK: - AlertPresenterDelegate
    func didReceiveAlert() { 
        loginTextField.text = ""
        passwordTextField.text = ""
    }
    
}

