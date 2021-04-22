//
//  TemperatureViewController.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 17/04/2021.
//

import UIKit

class TemperatureViewController: UIViewController {
    
    let service = RPIService()

    @IBOutlet var tempLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTemp()
    }
    
    @IBAction func refreshBtnPressed(_ sender: Any) {
        fetchTemp()
    }
    
    private func fetchTemp(){
        service.fetchTemperature { res in
            switch(res) {
            case .success(let messageResponse):
                DispatchQueue.main.async {
                    self.tempLbl.text = messageResponse.message
                }
            case .failure(let err):
                print(err)
            }
        }
    }

}
