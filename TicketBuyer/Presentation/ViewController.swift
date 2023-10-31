//
//  ViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 18.10.2023.
//

import UIKit

class ViewController: UIViewController, AlertPresenterDelegate {
    
    @IBOutlet weak var loginStackView: UIStackView!
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var generalImage: UIImageView!
    
    //Main Stack View Images
    @IBOutlet weak var firstMainStackViewImage: UIImageView!
    @IBOutlet weak var secondMainStackViewImage: UIImageView!
    @IBOutlet weak var thirdMainStackViewImage: UIImageView!
    
    @IBOutlet weak var firstSecScrollVImage: UIImageView!
    @IBOutlet weak var secondSecScrollVImage: UIImageView!
    @IBOutlet weak var thirdSecScrollVImage: UIImageView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
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
        logoutButton.layer.cornerRadius = 15
        mainStackView.isHidden = true

    }
    
    // MARK: - Private functions
    @IBAction private func loginButtonClick(_ sender: Any) {
        for user in usersGetSet.users {
            if (user.username == loginTextField.text)
                && (user.password == passwordTextField.text) {
                let viewModel = AlertModel(
                    title: "Успех",
                    message: "Вы вошли под администратором",
                    buttonText: "Продожить")
                
                alertPresenter.requestAlert(result: viewModel)
                
                loginStackView.isHidden = true
                mainStackView.isHidden = false

                loginTextField.isEnabled = false
                passwordTextField.isEnabled = false
                
            } else {
                let viewModel = AlertModel(
                    title: "Неудача",
                    message: "Вы ввели неправильный логин или пароль",
                    buttonText: "Продожить")
                alertPresenter.requestAlert(result: viewModel)
            }
            
        }
    }
    
    @IBAction func logoutButtonClick(_ sender: Any) {
        let viewModel = AlertModel(
            title: "Успех",
            message: "Вы вышли",
            buttonText: "Продожить")
        
        alertPresenter.requestAlert(result: viewModel)
        
        loginStackView.isHidden = false
        mainStackView.isHidden = true
        
        loginTextField.isEnabled = true
        passwordTextField.isEnabled = true
    }
    
    // MARK: - AlertPresenterDelegate
    func didReceiveAlert() { 
        loginTextField.text = ""
        passwordTextField.text = ""
    }
    
}

