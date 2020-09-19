//
//  VehicleViewController.swift
//  MiTier
//
//  Created by Alexander Klemt on 29.08.20.
//  Copyright © 2020 Arendai. All rights reserved.
//

import UIKit
import CoreBluetooth
import GDGauge

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
        label.font = .boldSystemFont(ofSize: 15)
        label2.font = .boldSystemFont(ofSize: 15)
        label3.font = .boldSystemFont(ofSize: 15)
        label4.font = .boldSystemFont(ofSize: 15)
        self.view.addSubview(label)
        self.view.addSubview(label2)
        self.view.addSubview(label3)
        self.view.addSubview(label4)
        updateData()
        
        
    }
    
    func updateData() {
            let gaugeView: GDGaugeView = GDGaugeView(frame: view.bounds)
            gaugeView.setupGuage(startDegree: 60, endDegree: 300, sectionGap: 5, minValue: 0, maxValue: 45)
            gaugeView.setupContainer(width: 100, color: .black, handleColor: .red, shouldShowContainerBorder: true, shouldShowFullCircle: true, indicatorsColor: .white, indicatorsValuesColor: .white, indicatorsFont: .boldSystemFont(ofSize: 15))
            gaugeView.setupUnitTitle(title: "KM/H")
            gaugeView.updateValueTo(CGFloat(mainview!.speednow))
            gaugeView.buildGauge()
        self.view.addSubview(gaugeView)
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            if(self.mainview!.connectedToVehicle == true) {
                self.mainview!.vehiclePeripheral.writeValue("AT+BKINF=\(self.mainview!.passwordController.passwordCB),".data(using: String.Encoding.utf8)!, for: self.mainview!.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
                self.mainview!.vehiclePeripheral.writeValue("1$\r\n".data(using: String.Encoding.utf8)!, for: self.mainview!.vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                self.label.text = "Serial Number: \(self.mainview!.vehicleAB)"
                self.calcRange()
                self.label2.text = "Battery: \(self.mainview!.battery)%"
                self.label3.text = "Range: \(self.vehicleRange)km"
                self.label4.text = "Total Range: \(self.mainview!.totalrange)km"
                gaugeView.updateValueTo(CGFloat(self.mainview!.speednow))
                if(self.mainview!.enabled) {
                    let on_image = UIImage(named: "on")
                    self.mainview!.scooterTapButton.setImage(on_image, for: .normal)
                }
                if(self.mainview!.enabled == false) {
                    let off_image = UIImage(named: "off")
                    self.mainview!.scooterTapButton.setImage(off_image, for: .normal)
                }
            } else {
                print("notconnect")
            }

            }
        
    }
    func calcRange() {
        let defaults = UserDefaults.standard
        let percentage = Double(mainview!.battery) ?? 0.0
        if( defaults.double(forKey: "SliderValue") == 0.0) {
            defaults.setValue(1.0, forKey: "SliderValue")
        }
        let speed = defaults.double(forKey: "SliderValue")
        let range1 = 20.0*35.0
        let range2 = range1/speed
        let battrange = (range2/100)*percentage
        
        
        vehicleRange = Int(battrange) ?? 0
        
    }

}
