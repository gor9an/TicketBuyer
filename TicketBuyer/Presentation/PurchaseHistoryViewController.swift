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
    var userEmails: [String] = []
    var selectedUserEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPickerView.delegate = self
        userPickerView.dataSource = self
        
        purchaseHistoryTextView.layer.cornerRadius = 15
        
        loadUserEmails()
    }
    
    func loadUserEmails() {
        db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Ошибка при загрузке пользователей: \(error.localizedDescription)")
                return
            }
            
            self.userEmails.removeAll()
            
            for document in querySnapshot?.documents ?? [] {
                let userEmail = document.documentID
                self.userEmails.append(userEmail)
            }
            
            self.userPickerView.reloadAllComponents()
            
            if let firstUserEmail = self.userEmails.first {
                self.selectedUserEmail = firstUserEmail
                self.loadPurchaseHistory()
            }
        }
    }
    
    func loadPurchaseHistory() {
        guard let selectedUserEmail = selectedUserEmail else { return }
        
        db.collection("users").document(selectedUserEmail).collection("purchases").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Ошибка при загрузке истории покупок: \(error.localizedDescription)")
                return
            }
            
            self.purchaseHistoryTextView.text = ""
            
            for document in querySnapshot?.documents ?? [] {
                let purchaseData = document.data()
                if let title = purchaseData["title"] as? String,
                   let seats = purchaseData["seats"] as? [Int],
                   let timestamp = purchaseData["timestamp"] as? Timestamp {
                    
                    let dateString = self.dateString(from: timestamp.dateValue())
                    
                    let purchaseInfo = "Фильм: \(title)\nСеанс: \(dateString)\nМеста: \(seats)\n\n"
                    
                    self.purchaseHistoryTextView.text += purchaseInfo
                }
            }
        }
    }
    
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
