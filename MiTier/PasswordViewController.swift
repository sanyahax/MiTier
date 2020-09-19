//
//  PasswordViewController.swift
//  MiTier
//
//  Created by Alexander Klemt on 29.08.20.
//  Copyright © 2020 Arendai. All rights reserved.
//

import UIKit
import iOSDropDown
import CoreBluetooth

class PasswordViewController: UIViewController {

    var mainview:ViewController?
    let defaults = UserDefaults.standard
    var passwordCB = "" // <== CHANGE TO HARDCODE
    let textFiled = UITextField(frame: CGRect(x: 180.0, y: 40.0, width: 100.0, height: 33.0))
    let textFiled2 = UITextField(frame: CGRect(x: 300.0, y: 40.0, width: 100.0, height: 33.0))
    let dropDown = DropDown(frame: CGRect(x: 20, y: 30, width: 150, height: 60)) // set frame
    let tierColor = UIColor(red: 106/255.0, green: 209/255.0, blue: 170/255.0, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordCB = defaults.string(forKey: "BLEPassword") ?? ""
        self.view.backgroundColor = .systemGray5
        dropDown.optionArray = ["AT+BKSCT=", "AT+BKLED=", "AT+BKECP="]
        dropDown.backgroundColor = .systemGray3
        dropDown.textColor = .black
        dropDown.rowBackgroundColor = .black
        dropDown.selectedRowColor = tierColor
        
        textFiled.backgroundColor = .white
        textFiled.textColor = .black
        textFiled.text = passwordCB
        textFiled.cornerRadius = 5
        textFiled2.borderStyle = UITextField.BorderStyle.line
        textFiled2.backgroundColor = .lightGray
        textFiled2.textColor = .black
        textFiled2.placeholder = "Params"
        textFiled2.cornerRadius = 5
        textFiled2.borderStyle = UITextField.BorderStyle.line
        
        self.view.addSubview(textFiled)
        self.view.addSubview(textFiled2)
        self.view.addSubview(dropDown)
        
        
        
        
        
        let button = UIButton(frame: CGRect(x: 150, y: 180, width: 100, height: 50))
        button.backgroundColor = tierColor
        button.cornerRadius = 25
        button.titleLabel?.textColor = .black
        button.setTitle("Write", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        self.view.addSubview(button)
    }

    @objc func buttonAction(sender: UIButton!) {
        defaults.set(textFiled.text!, forKey: "BLEPassword")
        print("Button tapped")
        if mainview!.connectedToVehicle {
            mainview!.vehiclePeripheral.writeValue(dropDown.text!.data(using: String.Encoding.utf8)!, for: mainview!.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            mainview!.vehiclePeripheral.writeValue("\(textFiled.text!),".data(using: String.Encoding.utf8)!, for: mainview!.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            mainview!.vehiclePeripheral.writeValue(textFiled2.text!.data(using: String.Encoding.utf8)!, for: mainview!.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            
            print("COMMAND WRITTEN: ", dropDown.text!,textFiled.text!,textFiled2.text!)
            let alert = UIAlertController(title: "Success", message: "Command written to Vehicle.", preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Vehicle not connected!", message: "Please make sure your Vehicle is working.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }

    func updatePass() {
        passwordCB = "\(textFiled.text!)"
        self.view.endEditing(true)
    }
    
    
    
}

