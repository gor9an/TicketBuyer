//
//  DeleteSessionViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 18.12.2023.
//

import UIKit
import FirebaseFirestore

class DeleteSessionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var moviePickerView: UIPickerView!
    @IBOutlet weak var sessionPickerView: UIPickerView!
    
    let db = Firestore.firestore()
    var movies: [Movie] = []
    var selectedMovie: Movie?
    var sessions: [MovieSession] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviePickerView.dataSource = self
        moviePickerView.delegate = self
        sessionPickerView.dataSource = self
        sessionPickerView.delegate = self
        
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
                
                guard self.movies.count != 0 else {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                self.moviePickerView.reloadAllComponents()
                self.loadSessionsForSelectedMovie()
            }
        }
    }
    
    func loadSessionsForSelectedMovie() {
        // Загрузить сеансы для выбранного фильма
        if let selectedMovie = selectedMovie {
            db.collection("movies").document(selectedMovie.movieID).collection("sessions").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Ошибка при загрузке сеансов: \(error.localizedDescription)")
                } else {
                    self.sessions = querySnapshot?.documents.compactMap { document in
                        let data = document.data()
                        let dateTime = (data["dateTime"] as? Timestamp)?.dateValue() ?? Date()

                        // Проверить, что сеанс еще не прошел
                        if dateTime > Date() {
                            return MovieSession(movieID: selectedMovie.movieID, dateTime: dateTime)
                        } else {
                            // Удалить сеанс, который уже прошел
                            self.deleteSessionFromFirestore(session: MovieSession(movieID: selectedMovie.movieID, dateTime: dateTime))
                            return nil
                        }
                    } ?? []

                    self.sessionPickerView.reloadAllComponents()
                }
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource and UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == moviePickerView {
            return movies.count
        } else {
            return sessions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == moviePickerView {
            return movies[row].title
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            return formatter.string(from: sessions[row].dateTime)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == moviePickerView {
            selectedMovie = movies[row]
            loadSessionsForSelectedMovie()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func deleteSession(_ sender: Any) {
        let selectedSessionIndex = sessionPickerView.selectedRow(inComponent: 0)
        if selectedSessionIndex < sessions.count {
            let selectedSession = sessions[selectedSessionIndex]
            deleteSessionFromFirestore(session: selectedSession)
        } else {
            showAlert(message: "Пожалуйста, выберите сеанс для удаления.")
        }
    }
    
    func deleteSessionFromFirestore(session: MovieSession) {
        db.collection("movies").document(session.movieID).collection("sessions").whereField("dateTime", isEqualTo: session.dateTime).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Ошибка при удалении сеанса: \(error.localizedDescription)")
                self.showAlert(message: "Ошибка при удалении сеанса. Пожалуйста, попробуйте еще раз.")
            } else {
                if let document = querySnapshot?.documents.first {
                    document.reference.delete { error in
                        if let error = error {
                            print("Ошибка при удалении сеанса: \(error.localizedDescription)")
                            self.showAlert(message: "Ошибка при удалении сеанса. Пожалуйста, попробуйте еще раз.")
                        } else {
                            print("Сеанс успешно удален из базы данных.")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
