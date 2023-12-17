//
//  AddMovieViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 14.12.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AddMovieViewController: UIViewController,
                              UIPickerViewDataSource,
                              UIPickerViewDelegate,
                              UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate,
                              UITextFieldDelegate,
                              UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var genrePickerView: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    
    let genres = ["Боевик", "Комедия", "Драма", "Фантастика", "Научная фантастика", "Триллер"] // Список доступных жанров
    var selectedGenre: String?
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genrePickerView.dataSource = self
        genrePickerView.delegate = self
        
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        
        imageView.layer.cornerRadius = 10
        
        descriptionTextView.layer.cornerRadius = 15
        
        imagePicker.delegate = self
    }
    
    // MARK: - UIPickerViewDataSource and UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genres.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genres[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGenre = genres[row]
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate, UITextViewDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func pickImage(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addMovie(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty,
              let genre = selectedGenre, !genre.isEmpty,
              let image = imageView.image else {
            // Показать предупреждение, что не все данные введены
            showAlert(message: "Пожалуйста, заполните все поля и выберите изображение.")
            return
        }
        
        // Преобразовать изображение в данные JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            // Обработать ошибку преобразования изображения
            showAlert(message: "Ошибка при обработке изображения.")
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
                
                // Создать объект Movie и отправить в Firestore с ссылкой на изображение
                let newMovie = Movie(title: title, description: description, genre: genre, imageURL: imageURL, movieID: "")
                self.addMovieToFirestore(movie: newMovie)
            }
        }
    }
    func addMovieToFirestore(movie: Movie) {
        var ref: DocumentReference? = nil
        ref = db.collection("movies").addDocument(data: [
            "title": movie.title,
            "description": movie.description,
            "genre": movie.genre,
            "imageURL": movie.imageURL
        ]) { error in
            if let error = error {
                print("Ошибка при добавлении фильма: \(error.localizedDescription)")
                self.showAlert(message: "Ошибка при добавлении фильма. Пожалуйста, попробуйте еще раз.")
            } else {
                let newMovieID = ref!.documentID
                print("Фильм успешно добавлен в базу данных. ID документа: \(newMovieID)")
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
