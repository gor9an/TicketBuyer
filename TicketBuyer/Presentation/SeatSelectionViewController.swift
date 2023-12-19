//
//  SeatSelectionViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 19.12.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SeatSelectionViewController: UIViewController {
    
    var selectedMovie: Movie?
    var selectedSession: MovieSession?
    var selectedSeats: [Int] = []
    
    @IBOutlet var seatButtons: [UIButton]!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBookedSeats()
    }
    
    func loadBookedSeats() {
        guard let movieID = selectedMovie?.movieID,
              let sessionID = selectedSession?.sessionID else { return }
        
        db.collection("movies").document(movieID).collection("sessions").document(sessionID).getDocument { (document, error) in
            if let error = error {
                print("Ошибка при загрузке забронированных мест: \(error.localizedDescription)")
                return
            }
            
            if let seatsData = document?.data()?["seats"] as? [String: Bool] {
                for (index, isEnabled) in seatsData {
                    if let seatIndex = Int(index), seatIndex < self.seatButtons.count {
                        self.seatButtons[seatIndex].isEnabled = isEnabled
                    }
                }
            }
        }
    }
    
    @IBAction func seatButtonTapped(_ sender: UIButton) {
        guard let seatIndex = seatButtons.firstIndex(of: sender) else {
            return
        }
        
        if selectedSeats.contains(seatIndex) {
            // Место уже выбрано, снимаем выбор
            selectedSeats.removeAll { $0 == seatIndex }
            sender.isSelected = false
        } else {
            // Выбираем место
            selectedSeats.append(seatIndex)
            sender.isSelected = true
        }
    }
    
    @IBAction func buyButtonTapped(_ sender: UIButton) {
        guard let movieID = selectedMovie?.movieID,
              let sessionID = selectedSession?.sessionID else {
            return
        }

        // Проверяем, подтвержден ли адрес электронной почты пользователя
        guard let currentUser = Auth.auth().currentUser, currentUser.isEmailVerified else {
            // Пользователь не подтвердил адрес электронной почты, выводим алерт
            showAlert(message: "Подтвердите адрес электронной почты для продолжения.")
            return
        }

        // Отправляем запрос на резервацию выбранных мест
        reserveSeats(movieID: movieID, sessionID: sessionID, seatIndices: selectedSeats)
    }

    
    func reserveSeats(movieID: String, sessionID: String, seatIndices: [Int]) {
        // Создаем словарь для обновления занятости мест
        var seatsData: [String: Bool] = [:]

        // Заполняем словарь
        for (index, isEnabled) in seatButtons.enumerated() {
            seatsData["\(index)"] = isEnabled.isEnabled
        }

        // Меняем статус выбранных мест
        for index in seatIndices {
            seatsData["\(index)"] = false
        }

        // Отправляем запрос на резервацию
        db.collection("movies").document(movieID).collection("sessions").document(sessionID).updateData([
            "seats": seatsData
        ]) { error in
            if let error = error {
                print("Ошибка при резервировании мест: \(error.localizedDescription)")
            } else {
                print("Места успешно забронированы.")
                self.dismiss(animated: true)
                
                self.addPurchaseToDatabase(movieID: movieID, sessionID: sessionID, selectedSeats: seatIndices)
            }
        }
    }
    
    // Добавляем информацию о покупке в базу данных
    func addPurchaseToDatabase(movieID: String, sessionID: String, selectedSeats: [Int]) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        guard let userEmail = currentUser.email else {
            // Адрес электронной почты пользователя не найден
            showAlert(message: "Не удалось получить адрес электронной почты пользователя.")
            return
        }

        // Создаем уникальный идентификатор для каждой покупки
        let purchaseID = UUID().uuidString

        // Создаем структуру данных для сохранения в коллекцию покупок пользователя
        let purchaseData: [String: Any] = [
            "movieID": movieID,
            "sessionID": sessionID,
            "seats": selectedSeats,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // Добавляем данные о покупке в коллекцию пользователя
        db.collection("users").document("\(userEmail)").collection("purchases").document(purchaseID).setData(purchaseData) { error in
            if let error = error {
                print("Ошибка при сохранении покупки: \(error.localizedDescription)")
            } else {
                print("Покупка успешно сохранена.")
                // Опционально: добавьте дополнительные действия при успешной покупке
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
