//
//  AddSessionViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 17.12.2023.
//

import UIKit
import FirebaseFirestore

class AddSessionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var moviePickerView: UIPickerView!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    
    let db = Firestore.firestore()
    var movies: [Movie] = [] // Список фильмов, полученных из базы данных
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviePickerView.dataSource = self
        moviePickerView.delegate = self
        
        dateTimePicker.minimumDate = Date()
        
        loadMovies()
    }
    
    func loadMovies() {
        // Загрузить список фильмов из базы данных
        db.collection("movies").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Ошибка при загрузке фильмов: \(error.localizedDescription)")
            } else {
                self.movies = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let genre = data["genre"] as? String ?? ""
                    let imageURL = data["imageURL"] as? String ?? ""
                    let movieID = document.documentID
                    
                    return Movie(title: title, description: description, genre: genre, imageURL: imageURL, movieID: movieID)
                } ?? []
                
                self.moviePickerView.reloadAllComponents()
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource and UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return movies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return movies[row].title
    }
    
    // MARK: - Actions
    
    @IBAction func addSession(_ sender: Any) {
        let selectedMovieIndex = moviePickerView.selectedRow(inComponent: 0)
        if selectedMovieIndex < movies.count {
            let selectedMovie = movies[selectedMovieIndex]
            let selectedDateTime = dateTimePicker.date
            let seats = ["0": true,
                         "1": true,
                         "2": true,
                         "3": true,
                         "4": true,
                         "5": true,
                         "6": true,
                         "7": true,
                         "8": true]
            
            // Добавить сеанс в подколлекцию sessions для выбранного фильма
            addSessionToFirestore(movieID: selectedMovie.movieID, dateTime: selectedDateTime, seats: seats)
        } else {
            // Показать предупреждение, что фильм не выбран
            showAlert(message: "Пожалуйста, выберите фильм.")
        }
    }
    
    func addSessionToFirestore(movieID: String, dateTime: Date, seats: [String: Bool]) {
        let movieRef = db.collection("movies").document(movieID)
        movieRef.collection("sessions").addDocument(data: [
            "dateTime": Timestamp(date: dateTime),
            "seats": seats
        ]) { error in
            if let error = error {
                print("Ошибка при добавлении сеанса: \(error.localizedDescription)")
                self.showAlert(message: "Ошибка при добавлении сеанса. Пожалуйста, попробуйте еще раз.")
            } else {
                print("Сеанс успешно добавлен в базу данных.")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
