//
//  TicketPurchaseViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 19.12.2023.
//

import UIKit
import FirebaseFirestore

class TicketPurchaseViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var moviePickerView: UIPickerView!
    @IBOutlet weak var sessionDatePickerView: UIPickerView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    let db = Firestore.firestore()
    var movies: [Movie] = []
    var selectedMovie: Movie?
    var sessions: [MovieSession] = []
    var selectedSession: MovieSession?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviePickerView.dataSource = self
        moviePickerView.delegate = self
        sessionDatePickerView.dataSource = self
        sessionDatePickerView.delegate = self
        
        imageView.layer.cornerRadius = 10
        descriptionTextView.layer.cornerRadius = 15
        
        loadMovies()
        
        updateMovieInformation()
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
                self.pickerView(self.moviePickerView, didSelectRow: 0, inComponent: 0)
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
                        let sessionID = document.documentID
                        let seats = (data["seats"] as? [String: Bool]) ?? [:]
                        
                        // Проверить, что сеанс еще не прошел
                        if dateTime > Date() {
                            return MovieSession(movieID: selectedMovie.movieID, dateTime: dateTime, sessionID: sessionID, seats: seats)
                        } else {
                            self.deleteSessionFromFirestore(session: MovieSession(movieID: selectedMovie.movieID, dateTime: dateTime, sessionID: sessionID, seats: seats))
                            
                            return nil
                        }
                    } ?? []
                    
                    // Отсортировать сеансы по времени
                    self.sessions.sort(by: { $0.dateTime < $1.dateTime })
                    self.pickerView(self.sessionDatePickerView, didSelectRow: 0, inComponent: 0)
                    self.sessionDatePickerView.reloadAllComponents()
                }
            }
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
                        }
                    }
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
            
            // Обновите информацию о фильме
            updateMovieInformation()
        } else if pickerView == sessionDatePickerView {
            if sessions.indices.contains(row) {
                selectedSession = sessions[row]
            }
        }
    }
    
    func updateMovieInformation() {
        guard let selectedMovie = selectedMovie else { return }
        
        genreLabel.text = "Жанр: \(selectedMovie.genre)"
        descriptionTextView.text = selectedMovie.description
        
        // Загрузите изображение фильма (используйте свой код для загрузки изображения)
        // movieImageView.image = ...
        
        // Ваш код загрузки изображения из URL может выглядеть следующим образом:
        if let imageURL = URL(string: selectedMovie.imageURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // Проверка, что фильм выбран
        guard let selectedMovie = selectedMovie else {
            showAlert(message: "Пожалуйста, выберите фильм.")
            return
        }
        
        // Проверка, что сеанс выбран
        guard let selectedSession = selectedSession else {
            showAlert(message: "Пожалуйста, выберите сеанс.")
            return
        }
        
        // Перейдите к следующему экрану и передайте данные
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "SeatSelectionViewController") as! SeatSelectionViewController
        newVC.selectedMovie = selectedMovie
        newVC.selectedSession = selectedSession
        
        self.present(newVC, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
