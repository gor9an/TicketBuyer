//
//  PurchaseHistoryViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 19.12.2023.
//

import UIKit
import FirebaseFirestore

class PurchaseHistoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var userPickerView: UIPickerView!
    @IBOutlet weak var purchaseHistoryTextView: UITextView!
    
    let db = Firestore.firestore()
    var userEmails: [String] = []  // Массив для хранения email пользователей
    var selectedUserEmail: String?  // Выбранный email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPickerView.delegate = self
        userPickerView.dataSource = self
        
        purchaseHistoryTextView.layer.cornerRadius = 15
        
        // Загружаем список email пользователей
        loadUserEmails()
    }
    
    // Загрузка списка email пользователей
    func loadUserEmails() {
        db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Ошибка при загрузке пользователей: \(error.localizedDescription)")
                return
            }
            
            // Очищаем массив перед добавлением новых email
            self.userEmails.removeAll()
            
            // Добавляем email в массив
            for document in querySnapshot?.documents ?? [] {
                let userEmail = document.documentID
                self.userEmails.append(userEmail)
            }
            
            // Обновляем pickerView
            self.userPickerView.reloadAllComponents()
            
            // Выбираем первый email, если он есть
            if let firstUserEmail = self.userEmails.first {
                self.selectedUserEmail = firstUserEmail
                self.loadPurchaseHistory()
            }
        }
    }
    
    // Загрузка истории покупок для выбранного пользователя
    func loadPurchaseHistory() {
        guard let selectedUserEmail = selectedUserEmail else { return }
        
        // Получаем коллекцию покупок пользователя
        db.collection("users").document(selectedUserEmail).collection("purchases").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Ошибка при загрузке истории покупок: \(error.localizedDescription)")
                return
            }
            
            // Очищаем textView перед добавлением новых данных
            self.purchaseHistoryTextView.text = ""
            
            // Добавляем информацию о каждой покупке в textView
            for document in querySnapshot?.documents ?? [] {
                let purchaseData = document.data()
                if let movieID = purchaseData["movieID"] as? String,
                   let sessionID = purchaseData["sessionID"] as? String,
                   let seats = purchaseData["seats"] as? [Int],
                   let timestamp = purchaseData["timestamp"] as? Timestamp {
                    
                    let dateString = self.dateString(from: timestamp.dateValue())
                    
                    let purchaseInfo = "Фильм: \(movieID)\nСеанс: \(sessionID)\nМеста: \(seats)\nДата: \(dateString)\n\n"
                    
                    self.purchaseHistoryTextView.text += purchaseInfo
                }
            }
        }
    }
    
    // Форматирование даты в строку
    func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userEmails.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userEmails[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUserEmail = userEmails[row]
        loadPurchaseHistory()
    }
}
