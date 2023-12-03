//
//  AdminViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 03.12.2023.
//

import UIKit
import FirebaseFirestore

class AdminViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    var date: String = ""
    @IBOutlet weak var addMovieButton: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    let db = Firestore.firestore()
    
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Устанавливаем dateTextField в качестве источника для выбора даты
        datePicker.minimumDate = Date()
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        date = formatDate(selectedDate!)
    }
    
    @objc func doneButtonTapped() {
        view.endEditing(true) // Закрытие клавиатуры
    }
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty, let selectedDate = selectedDate else {
            // Показать предупреждение, что не все данные введены
            return
        }
        
        let newMovie = Movie(title: title, sessions: [selectedDate])
        
        addMovieToFirestore(movie: newMovie)
    }
    
    func addMovieToFirestore(movie: Movie) {
        var ref: DocumentReference? = nil
        ref = db.collection("movies").addDocument(data: [
            "title": movie.title,
            "sessions": movie.sessions
        ]) { error in
            if let error = error {
                print("Ошибка при добавлении фильма: \(error.localizedDescription)")
            } else {
                print("Фильм успешно добавлен в базу данных. ID документа: \(ref!.documentID)")
                // После успешного добавления, вы можете выполнить дополнительные действия
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
