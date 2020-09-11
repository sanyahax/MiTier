//
//  VehicleViewController.swift
//  MiTier
//
//  Created by Alexander Klemt on 29.08.20.
//  Copyright © 2020 Arendai. All rights reserved.
//

import UIKit
import CoreBluetooth

class VehicleViewController: UIViewController {
    
    var mainview:ViewController?
    var passview:PasswordViewController!
    var vehicleBatt = 100
    var vehicleRange = 0
    var vehicleTotal = 0
    let label = UILabel(frame: CGRect(x: 0, y: 75, width: 600, height: 21))
    let label2 = UILabel(frame: CGRect(x: 0, y: 100, width: 600, height: 21))
    let label3 = UILabel(frame: CGRect(x: 0, y: 125, width: 600, height: 21))
    let label4 = UILabel(frame: CGRect(x: 0, y: 150, width: 600, height: 21))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemGray5

        label.text = "Serial Number: \(mainview!.vehicleAB)"
        label2.text = "Battery: \(mainview!.battery)%"
        label3.text = "Range: \(vehicleRange)km"
        label4.text = "Total: \(mainview!.totalrange)km"
        self.view.addSubview(label)
        self.view.addSubview(label2)
        self.view.addSubview(label3)
        self.view.addSubview(label4)
        updateData()
        
        
    }
    
    func updateData() {
            
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if(self.mainview!.connectedToVehicle) {
                self.mainview!.vehiclePeripheral.writeValue("AT+BKINF=\(self.mainview!.passwordController.passwordCB),".data(using: String.Encoding.utf8)!, for: self.mainview!.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
                self.mainview!.vehiclePeripheral.writeValue("1$\r\n".data(using: String.Encoding.utf8)!, for: self.mainview!.vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                self.label.text = "Serial Number: \(self.mainview!.vehicleAB)"
                self.calcRange()
                self.label2.text = "Battery: \(self.mainview!.battery)%"
                self.label3.text = "Range: \(self.vehicleRange)km"
                self.label4.text = "Total Range: \(self.mainview!.totalrange)km"
                if(self.mainview!.enabled) {
                    let on_image = UIImage(named: "on")
                    self.mainview!.scooterTapButton.setImage(on_image, for: .normal)
                }
                if(self.mainview!.enabled == false) {
                    let off_image = UIImage(named: "off")
                    self.mainview!.scooterTapButton.setImage(off_image, for: .normal)
                }
            }

            }
        
    }
    func calcRange() {
        let percentage = Double(mainview!.battery) ?? 0
        let speed = Double(mainview!.speedkmh) ?? 20
        var nigga = 35.0
        if speed > 30 {
            nigga = 20.0
        } else if speed > 26 {
            nigga = 27.5
        } else if speed > 21{
            nigga = 35.0
        }
        vehicleRange = Int(((nigga/100.0)*percentage))
        
    }

}
