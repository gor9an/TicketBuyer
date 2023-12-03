//
//  BuyViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 03.12.2023.
//

import UIKit
import Firebase

class BuyViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var movies: [Movie] = [] {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
//    func fetchMoviesFromFirestore() {
//        db.collection("movies").getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Ошибка при получении данных: \(error.localizedDescription)")
//            } else {
//                var moviesArray: [Movie] = []
//
//                for document in snapshot!.documents {
//                    let data = document.data()
//                    if let title = data["title"] as? String,
//                       let sessions = data["sessions"] as? [String:[String]] {
//                       let movie = Movie(title: title, sessions: sessions)
//                       moviesArray.append(movie)
//                    }
//                }
//
//                self.movies = moviesArray
//                print("Получены фильмы из базы данных: \(self.movies)")
//            }
//        }
//    }
//}
//    
//    // MARK: - UIPickerView
//    extension BuyViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//        
//        func numberOfComponents(in pickerView: UIPickerView) -> Int {
//            return 1 // Одна компонента (один столбец)
//        }
//        
//        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//            return movies.count // Количество фильмов
//        }
//        
//        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//            return movies[row].title // Заголовок для каждого фильма
//        }
        
//        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//            let selectedMovie = movies[row]
//            textField.text = selectedMovie.title
//            pickerView.isHidden = true
//        }
    }
