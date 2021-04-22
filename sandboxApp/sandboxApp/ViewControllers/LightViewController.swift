//
//  LightViewController.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 17/04/2021.
//

import UIKit

class LightViewController: UIViewController {
    
    let service = RPIService()
    @IBOutlet var stateLbl: UILabel!
    @IBOutlet var lightSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func lightSwitchPressed(_ sender: UISwitch) {
        print(sender.isOn)
        service.toggleLight(requestModel: LightRequestModel(toggleOn: sender.isOn )){ res in
            switch (res) {
                case .success(let messageResponse):
                    DispatchQueue.main.async {
                        self.view.backgroundColor = sender.isOn ? .white : .black
                        self.stateLbl.textColor = sender.isOn ? .systemGreen : .white
                        self.stateLbl.text = sender.isOn ? "ON" : "OFF"
                    }
                    print(messageResponse.message)
                case .failure(let err):
                    print(err)
                    DispatchQueue.main.async {
                        self.lightSwitch.isOn  = !sender.isOn
                    }
            }
        }
    }
    
}
