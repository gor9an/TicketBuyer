//
//  EditMovieViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 18.12.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class EditMovieViewController: UIViewController,
                               UIPickerViewDataSource,
                               UIPickerViewDelegate,
                               UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate,
                               UITextViewDelegate{
    
    @IBOutlet weak var moviePickerView: UIPickerView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var genrePickerView: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    
    let genres = ["Боевик", "Комедия", "Драма", "Фантастика", "Научная фантастика", "Триллер"]
    var selectedGenre: String?
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var movies: [Movie] = []
    var selectedMovie: Movie?
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviePickerView.dataSource = self
        moviePickerView.delegate = self
        genrePickerView.dataSource = self
        genrePickerView.delegate = self
        
        descriptionTextView.delegate = self
        
        imagePicker.delegate = self
        
        imageView.layer.cornerRadius = 10
        descriptionTextView.layer.cornerRadius = 15
        
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
                    let movieID = document.documentID
                    return Movie(title: title, description: description, genre: genre, imageURL: imageURL, movieID: movieID)
                } ?? []
                
                guard self.movies.count != 0 else {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                
                // Обновите данные в pickerView после загрузки фильмов
                self.moviePickerView.reloadAllComponents()
                self.genrePickerView.reloadAllComponents()
                
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
        if pickerView == moviePickerView {
            return movies.count
        } else if pickerView == genrePickerView {
            return genres.count
        }
        return 0
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == moviePickerView {
            return movies[row].title
        } else if pickerView == genrePickerView {
            return genres[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == moviePickerView {
            selectedMovie = movies[row]
            updateUI()
        } else if pickerView == genrePickerView {
            selectedGenre = genres[row]
        }
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
        
        // Преобразовать изображение в данные JPEG
        guard let image = imageView.image,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            showAlert(message: "Пожалуйста, выберите изображение.")
            return
        }
        
        // Создать уникальное имя файла для изображения
        let imageName = UUID().uuidString
        let imageRef = storage.reference().child("movie_images").child(imageName)
        
        // Загрузить изображение в Firebase Storage
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil, error == nil else {
                // Обработать ошибку загрузки изображения
                self.showAlert(message: "Ошибка при загрузке изображения.")
                return
            }
            
            // Получить URL загруженного изображения
            imageRef.downloadURL { (url, error) in
                guard let imageURL = url?.absoluteString else {
                    // Обработать ошибку получения URL изображения
                    self.showAlert(message: "Ошибка при получении URL изображения.")
                    return
                }
                
                // Обновите данные в Firestore
                self.db.collection("movies").document(selectedMovie.movieID).updateData([
                    "description": description,
                    "genre": genre,
                    "imageURL": imageURL
                ]) { error in
                    if let error = error {
                        print("Ошибка при обновлении фильма: \(error.localizedDescription)")
                        self.showAlert(message: "Ошибка при обновлении фильма. Пожалуйста, попробуйте еще раз.")
                    } else {
                        print("Фильм успешно обновлен в базе данных.")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func changeImage(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteMovie(_ sender: Any) {
        guard let selectedMovie = selectedMovie else {
            showAlert(message: "Выберите фильм для удаления.")
            return
        }
        
        let alert = UIAlertController(title: "Удалить фильм?", message: "Вы уверены, что хотите удалить выбранный фильм?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { _ in
            // Удаление фильма из Firestore
            self.db.collection("movies").document(selectedMovie.movieID).delete { error in
                if let error = error {
                    print("Ошибка при удалении фильма: \(error.localizedDescription)")
                    self.showAlert(message: "Ошибка при удалении фильма. Пожалуйста, попробуйте еще раз.")
                } else {
                    print("Фильм успешно удален из базы данных.")
                    // Выполните дополнительные действия после удаления фильма
                    self.clearUI()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // Очистка UI после удаления фильма
    func clearUI() {
        descriptionTextView.text = ""
        imageView.image = nil
        selectedMovie = nil
        selectedGenre = nil
        moviePickerView.reloadAllComponents()
        genrePickerView.reloadAllComponents()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
