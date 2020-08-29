//
//  PasswordViewController.swift
//  MiTier
//
//  Created by Alexander Klemt on 29.08.20.
//  Copyright © 2020 Arendai. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {

    var mainview:ViewController?
    
    var passwordCB = "null"
   let textFiled = UITextField(frame: CGRect(x: 20.0, y: 30.0, width: 100.0, height: 33.0))
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemGray5
        
        textFiled.backgroundColor = .white
        textFiled.textColor = .black
        textFiled.borderStyle = UITextField.BorderStyle.line
        self.view.addSubview(textFiled)
        
        passwordCB = "\(textFiled.text!)"
    }
    
    
    func updatePass() {
        passwordCB = "\(textFiled.text!)"
        self.view.endEditing(true)
    }

}
