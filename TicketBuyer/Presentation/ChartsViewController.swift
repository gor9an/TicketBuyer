//
//  ChartsViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 19.12.2023.
//

import UIKit
import FirebaseFirestore
import DGCharts

class ChartViewController: UIViewController {
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    let db = Firestore.firestore()
    var movies: [Movie] = []
    var movieTicketsData: [PieChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMovies()
    }
    
    func loadMovies() {
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
                
                self.loadMovieSession()
            }
        }
    }
    
    func loadMovieSession() {
        for movie in movies {
            db.collection("movies").document(movie.movieID).collection("sessions").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Ошибка при загрузке сеансов \(movie.title): \(error.localizedDescription)")
                } else {
                    let ticketsCount = querySnapshot?.documents.count ?? 0
                    let entry = PieChartDataEntry(value: Double(ticketsCount), label: movie.title)
                    self.movieTicketsData.append(entry)
                    
                    if self.movieTicketsData.count == self.movies.count {
                        self.setupPieChart()
                    }
                }
            }
        }
    }
    
    func setupPieChart() {
        // Создаем набор данных для круговой диаграммы
        let dataSet = PieChartDataSet(entries: movieTicketsData, label: "Количество сеансов")
        dataSet.colors = ChartColorTemplates.material()
        
        // Создаем объект данных для круговой диаграммы
        let data = PieChartData(dataSet: dataSet)
        
        // Настраиваем параметры круговой диаграммы
        pieChartView.usePercentValuesEnabled = true
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        // Устанавливаем данные для круговой диаграммы
        pieChartView.data = data
    }
}
