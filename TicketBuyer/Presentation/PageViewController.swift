//
//  ViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 18.10.2023.
//

import UIKit
import Firebase

class PageViewController: UIViewController {
    
    @IBOutlet weak var generalImage: UIImageView!
    
    @IBOutlet weak var emailLabel: UINavigationItem!
    //Main Stack View Images
    @IBOutlet weak var firstMainStackViewButton: UIButton!
    @IBOutlet weak var secondMainStackViewButton: UIButton!
    @IBOutlet weak var thirdMainStackViewButton: UIButton!
    
    @IBOutlet weak var actualScrollView: UIScrollView!
    
    @IBOutlet weak var adminButton: UIButton!
    
    let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                self.showModalAuth()
            } else {
                if let currentUser = Auth.auth().currentUser, !currentUser.isEmailVerified {
                    self.showModalAuth()
                }
                self.checkAdmin()
                self.emailLabel.title = Auth.auth().currentUser?.email
                self.loadRandomMovieImage()
            }
        }
        
        actualScrollView.layer.cornerRadius = 30
        
        firstMainStackViewButton.layer.cornerRadius = 30
        secondMainStackViewButton.layer.cornerRadius = 30
        thirdMainStackViewButton.layer.cornerRadius = 30
        
        generalImage.layer.cornerRadius = 30
        
        adminButton.layer.cornerRadius = 20
        
    }
    
    //    MARK: - Private funcions
    
    func loadRandomMovieImage() {
        db.collection("movies")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Ошибка при загрузке случайного фильма: \(error.localizedDescription)")
                } else {
                    let randomMovie = querySnapshot?.documents.randomElement().flatMap { document -> Movie? in
                        let data = document.data()
                        let title = data["title"] as? String ?? ""
                        let imageURL = data["imageURL"] as? String ?? ""
                        let movieID = document.documentID
                        
                        return Movie(title: title, description: "", genre: "", imageURL: imageURL, movieID: movieID)
                    }
                    
                    if let randomMovie = randomMovie {
                        self.setRandomMovieImage(randomMovie)
                    }
                }
            }
    }
    
    func setRandomMovieImage(_ movie: Movie) {
        DispatchQueue.global().async {
            if let url = URL(string: movie.imageURL), let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.generalImage.image = UIImage(data: data)
                }
            }
        }
    }
    
    
    private func checkAdmin() {
        if let currentUser = Auth.auth().currentUser {
            let expectedUid = "TKzdo45kYhdb6skaruTgAx3bAwm2"
            
            if currentUser.uid == expectedUid {
                adminButton.isHidden = false
            } else {
                adminButton.isHidden = true
            }
        }
    }
    
    //    MARK: - IBActions
    @IBAction func exitButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    private func showModalAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "AuthController") as! AuthViewController
        newVC.modalPresentationStyle = .fullScreen
        
        self.present(newVC, animated: true, completion: nil)
    }
}

