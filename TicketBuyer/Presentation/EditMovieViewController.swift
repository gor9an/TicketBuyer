//
//  EditMovieViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 18.12.2023.
//

import UIKit

import UIKit
import FirebaseFirestore

class EditMovieViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var moviePickerView: UIPickerView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var genrePickerView: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    
    let genres = ["Action", "Comedy", "Drama", "Fantasy", "Sci-Fi", "Thriller"] // Список доступных жанров
    var selectedGenre: String?
    
    let db = Firestore.firestore()
    var movies: [Movie] = []
    var selectedMovie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviePickerView.dataSource = self
        moviePickerView.delegate = self
        genrePickerView.dataSource = self
        genrePickerView.delegate = self
        
        loadMovies()
    }
    
    func loadMovies() {
        db.collection("movies").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Ошибка при получении данных: \(error.localizedDescription)")
            } else {
                self.movies = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let genre = data["genre"] as? String ?? ""
                    let imageURL = data["imageURL"] as? String ?? ""
                    return Movie(title: title, description: description, genre: genre, imageURL: imageURL)
                } ?? []
                
                // Обновите данные в pickerView после загрузки фильмов
                self.moviePickerView.reloadAllComponents()
                
                // Вызовите метод для обновления UI после выбора фильма
                self.pickerView(self.moviePickerView, didSelectRow: 0, inComponent: 0)
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMovie = movies[row]
        updateUI()
    }
    
    // MARK: - Update UI with selected movie
    
    func updateUI() {
        guard let selectedMovie = selectedMovie else {
            return
        }
        
        descriptionTextView.text = selectedMovie.description
        if let genreIndex = genres.firstIndex(of: selectedMovie.genre) {
            genrePickerView.selectRow(genreIndex, inComponent: 0, animated: true)
            selectedGenre = selectedMovie.genre
        }
        
        // Загрузите изображение из URL и установите в imageView
        if let imageURL = URL(string: selectedMovie.imageURL) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageURL),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func updateMovie(_ sender: Any) {
        guard let selectedMovie = selectedMovie else {
            showAlert(message: "Выберите фильм для редактирования.")
            return
        }
        
        guard let description = descriptionTextView.text, !description.isEmpty,
              let genre = selectedGenre, !genre.isEmpty else {
            showAlert(message: "Пожалуйста, заполните все обязательные поля.")
            return
        }
        // Обновите данные в Firestore
        db.collection("movies").document(selectedMovie.title).updateData([
            "description": description,
            "genre": genre
            // Если вы также хотите обновить изображение, добавьте "imageURL": newImageURL
        ]) { error in
            if let error = error {
                print("Ошибка при обновлении фильма: \(error.localizedDescription)")
                self.showAlert(message: "Ошибка при обновлении фильма. Пожалуйста, попробуйте еще раз.")
            } else {
                print("Фильм успешно обновлен в базе данных.")
                // После успешного обновления, вы можете выполнить дополнительные действия
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
