//
//  LoginViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 01.11.2023.
//

import UIKit

class LoginViewController: UIViewController, AlertPresenterDelegate {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    private var usersGetSet: User = User()
    private var alertPresenter: AlertPresenterProtocol = AlertPresenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter.delegate = self
        loginButton.layer.cornerRadius = 15
    }
    
    // MARK: - Private function
    @IBAction func loginButtonTap(_ sender: Any) {
        for user in usersGetSet.users {
            if (user.username == loginTextField.text)
                && (user.password == passwordTextField.text) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(identifier: "MainViewController")
                
                let viewModel = AlertModel(
                    title: "Успех",
                    message: "Вы вошли под администратором",
                    buttonText: "Продожить")
                
                alertPresenter.requestAlert(result: viewModel)
                
                loginTextField.isEnabled = false
                passwordTextField.isEnabled = false
                
                self.present(viewController, animated: true, completion: nil)
                break
                 
            } else {
                let viewModel = AlertModel(
                    title: "Неудача",
                    message: "Вы ввели неправильный логин или пароль",
                    buttonText: "Продожить")
                alertPresenter.requestAlert(result: viewModel)
                break
                
            }
        }
    }
    
    func didReceiveAlert() {
        loginTextField.text = ""
        passwordTextField.text = ""
    }
}
