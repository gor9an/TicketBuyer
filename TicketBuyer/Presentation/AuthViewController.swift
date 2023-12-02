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
            } else {
                titleLabel.text = "Вход"
                switchButton.setTitle("Зарегистрироваться", for: .normal)
                firstNameTextField.isHidden = true
                lastNameTextField.isHidden = true
            }
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
    
    
    @IBAction func switchButtonTapped(_ sender: Any) {
        signUp = !signUp
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func didReceiveAlert() {}
    
}

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
                            
//                            let db
                        }
                    } else {
                        let viewModel = AlertModel(
                            title: "Ошибка",
                            message: "\(String(describing: error?.localizedDescription))",
                            buttonText: "Продожить")
                        self.alertPresenter.requestAlert(result: viewModel)
                    }
                }
            } else {
                alertPresenter.requestAlert(result: viewModel)
            }
            
        }else {
            if (!email.isEmpty && !password.isEmpty) {
                
            } else {
                alertPresenter.requestAlert(result: viewModel)
            }
            
        }
        
        return true
    }
}
