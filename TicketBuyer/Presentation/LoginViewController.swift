//
//  LoginViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 01.12.2023.
//

import UIKit

class LoginViewController: UIViewController, AlertPresenterDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var alertPresenter: AlertPresenterProtocol = AlertPresenter()
    
    private var usersGetSet: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertPresenter.delegate = self
    }
    

    // MARK: - Private functions
    @IBAction private func loginButtonTapped(_ sender: Any) {
        for user in usersGetSet.users {
            if (user.username == emailTextField.text)
                && (user.password == passwordTextField.text) {
                let viewModel = AlertModel(
                    title: "Успех",
                    message: "Вы вошли под администратором",
                    buttonText: "Продожить")
                
                alertPresenter.requestAlert(result: viewModel)
                
                
            } else {
                let viewModel = AlertModel(
                    title: "Неудача",
                    message: "Вы ввели неправильный логин или пароль",
                    buttonText: "Продожить")
                alertPresenter.requestAlert(result: viewModel)
            }
            
        }
    }
    
//    @IBAction func logoutButtonClick(_ sender: Any) {
//        let viewModel = AlertModel(
//            title: "Успех",
//            message: "Вы вышли",
//            buttonText: "Продожить")
//        
//        alertPresenter.requestAlert(result: viewModel)
//        
//
//        
//        emailTextField.isEnabled = true
//        passwordTextField.isEnabled = true
//    }
    
    // MARK: - AlertPresenterDelegate
    func didReceiveAlert() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }

}
