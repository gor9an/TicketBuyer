//
//  AuthViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 01.12.2023.
//

import UIKit
import Firebase

class AuthViewController: UIViewController, AlertPresenterDelegate {
    
    var signUp: Bool = true {
        willSet {
            if newValue {
                titleLabel.text = "Регистрация"
                switchButton.setTitle("Войти", for: .normal)
                firstNameTextField.isHidden = false
                lastNameTextField.isHidden = false
                
                firstNameTextField.text = ""
                lastNameTextField.text = ""
                emailTextField.text = ""
                passwordTextField.text = ""
                
                notificationLabel.text = "У вас уже есть аккаунт?"
            } else {
                titleLabel.text = "Вход"
                switchButton.setTitle("Зарегистрироваться", for: .normal)
                firstNameTextField.isHidden = true
                lastNameTextField.isHidden = true
                
                emailTextField.text = ""
                passwordTextField.text = ""
                
                notificationLabel.text = "У вас нет аккаунта?"
            }
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var switchButton: UIButton!
    
    private var alertPresenter: AlertPresenterProtocol = AlertPresenter()
    
    let viewModel = AlertModel(
        title: "Ошибка",
        message: "Заполните все поля",
        buttonText: "Продожить")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        alertPresenter.delegate = self
    }
    
    //    MARK: - IBActions
    @IBAction private func switchButtonTapped(_ sender: Any) {
        signUp = !signUp
    }
    
    
}

// MARK: - AuthViewController extension
extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let firstname = firstNameTextField.text!
        let lastname = lastNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if signUp {
            if (!firstname.isEmpty && !lastname.isEmpty && !email.isEmpty && !password.isEmpty) {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if error == nil {
                        if let result {
                            print(result.user.uid)
                            
                            let reference = Database.database().reference().child("users")
                            reference.child(result.user.uid).updateChildValues(["firstname": firstname, "email": email])
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        if let error {
                            let viewModel = AlertModel(
                                title: "Ошибка",
                                message: "\(String(describing: error.localizedDescription))",
                                buttonText: "Продожить")
                            self.alertPresenter.requestAlert(result: viewModel)
                        }
                    }
                }
            } else {
                alertPresenter.requestAlert(result: viewModel)
            }
            
        }else {
            if (!email.isEmpty && !password.isEmpty) {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if error == nil {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                alertPresenter.requestAlert(result: viewModel)
            }
            
        }
        
        return true
    }
    
    //    MARK: - AlertPresenterDelegate
    func didReceiveAlert() {}
}
