//
//  BuyViewController.swift
//  TicketBuyer
//
//  Created by Andrey Gordienko on 03.12.2023.
//

import UIKit

class BuyViewController: UIViewController,
                         UIPickerViewDelegate,
                         UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
// MARK: - UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        <#code#>
    }

}
