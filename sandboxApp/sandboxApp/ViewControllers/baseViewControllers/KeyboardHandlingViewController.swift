//
//  KeyboardHandlingViewController.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 21/04/2021.
//

import UIKit

class KeyboardHandlingViewController: UIViewController {
    
    var currentTextField: UITextField? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // keyboard
        // move screen when keyboard opened
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
      
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                
        // click screen: closes keyboard
        let tapOnScreen = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapOnScreen)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
            
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           return
        }
                
        if let current = self.currentTextField {
            let viewControllerBotttom = self.view.frame.maxY
            let yPosKeyboardTop = viewControllerBotttom - keyboardSize.height
            let bottomCurrentField = current.convert(current.bounds, to:self.view).maxY

            if bottomCurrentField > yPosKeyboardTop {
                self.view.frame.origin.y = 0 - keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
      self.view.frame.origin.y = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}



extension KeyboardHandlingViewController : UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.currentTextField = nil
    }
    
}
