//
//  DisplayViewController.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 17/04/2021.
//

import UIKit

class DisplayViewController: KeyboardHandlingViewController {

    let service = RPIService()
    @IBOutlet var mainLbl: UILabel!
    var number = 0 {
        didSet {
            displayNumber(number)
        }
    }
    
    @IBOutlet var numberField: UITextField!
    @IBOutlet var stepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberField.text = String(number)
        stepper.value = Double(number)
        stepper.minimumValue = 0
        stepper.maximumValue = 9999
        stepper.stepValue = 1
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        number = Int(sender.value)
        numberField.text = String(sender.value)
    }
    
    @IBAction func numberFieldEdited(_ sender: UITextField) {
        if let text = sender.text,
           let number = Int(text),
           number >= 0 && number <= 9999 {
            mainLbl.textColor = .black
            numberField.text = String(number)
            stepper.value = Double(number)
            self.number = number
        } else {
            mainLbl.textColor = .red
        }

    }
    
    private func displayNumber(_ number: Int){
        service.displayNumber(requestModel: DisplayNumberRequestModel(number: number)) { res in
            switch res {
                case .success(let messageResponse):
                    print(messageResponse)
                case .failure(let err):
                    print(err)
            }
        }
    }
    
}
