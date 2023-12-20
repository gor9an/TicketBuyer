//
//  AuthViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 01.12.2023.
//

import UIKit
import Firebase

class AuthViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //    MARK: - IBActions
    @IBAction private func switchButtonTapped(_ sender: Any) {
        signUp = !signUp
    }
    
    func sendEmailVerification(user: User) {
        user.sendEmailVerification { error in
            if let error = error {
                print("Ошибка при отправке письма с подтверждением: \(error.localizedDescription)")
                // Дополнительная обработка ошибок
            } else {
                print("Письмо с подтверждением успешно отправлено")
                // Дополнительные действия после успешной отправки письма
            }
        }
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
                            reference.child(result.user.uid).updateChildValues(["displayName": firstname, "email": email])
                            
                            self.sendEmailVerification(user: result.user)
                            self.showAlert(message: "Подтвердите адрес электронной почты для продолжения.")
                            
                            self.firstNameTextField.text = ""
                            self.lastNameTextField.text = ""
                            self.emailTextField.text = ""
                            self.passwordTextField.text = ""
                        }
                    } else {
                        if let error {
                            self.showAlert(message: String(describing: error.localizedDescription))
                        }
                    }
                }
            } else {
                self.showAlert(message: "Заполните все поля")
            }
            
        }else {
            if (!email.isEmpty && !password.isEmpty) {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if error == nil {
                        guard let currentUser = Auth.auth().currentUser, currentUser.isEmailVerified else {
                            self.showAlert(message: "Подтвердите адрес электронной почты для продолжения.")
                            return
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self.showAlert(message: "Заполните все поля")
            }
            
        }
        
        return true
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
