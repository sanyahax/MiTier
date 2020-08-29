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
    var vehicleABN = ""
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
        let vehicleAB = mainview!.vehicleAB
        vehicleABN = vehicleAB

        label.text = "Serial Number: \(vehicleAB)"
        label2.text = "Battery: \(vehicleBatt)%"
        label3.text = "Range: \(vehicleRange)km"
        label4.text = "Total: \(vehicleTotal)km"
        self.view.addSubview(label)
        self.view.addSubview(label2)
        self.view.addSubview(label3)
        self.view.addSubview(label4)
        //updateData()
    }
    
    func updateData() {
            
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            if(self.mainview!.connectedToVehicle) {
                self.vehicleABN = self.mainview!.vehicleAB
                self.label.text = "Serial Number: \(self.vehicleABN)"
                print(self.mainview!.vehiclePeripheral.readValue(for: self.mainview!.vehicleCharacteristic))
                self.label2.text = "Battery: \(self.mainview!.vehiclePeripheral.readValue(for: self.mainview!.vehicleCharacteristic))%"
            }

            }
        
    }

}
