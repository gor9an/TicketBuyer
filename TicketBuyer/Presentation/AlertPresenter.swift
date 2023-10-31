//
//  AlertPresenter.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 31.10.2023.
//

import UIKit

class AlertPresenter: UIViewController, AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?
    
    func requestAlert(result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.delegate?.didReceiveAlert()
        }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
