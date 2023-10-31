//
//  AlertPresenterProtocol.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 31.10.2023.
//

import Foundation

protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate? { get set }
    func requestAlert(result: AlertModel)
}
