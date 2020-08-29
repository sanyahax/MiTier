//
//  ViewController.swift
//  MiTier
//
//  Created by Alexander Klemt on 27.08.20.
//  Copyright © 2020 Arendai. All rights reserved.
//

import UIKit
import SideMenu
import CoreBluetooth
import iOSDropDown

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}

extension ViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
            
        case .unknown:
            print("CB.state is unknown")
        case .resetting:
            print("CB.state is reset")
        case .unsupported:
            print("CB.state is unsupported")
        case .unauthorized:
            print("CB.state is unauth")
        case .poweredOff:
            print("CB.state is off")
        case .poweredOn:
            print("CB.state is on")
            centralManager.scanForPeripherals(withServices: services)
            
        @unknown default:
            print("default")
        }
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        vehiclePeripheral = peripheral
        centralManager.stopScan()
        if vehiclePeripheral.name!.contains("AB") {
            centralManager.connect(vehiclePeripheral)
        }
        
        vehiclePeripheral.delegate = self
        print(vehiclePeripheral ?? "")
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("Connected!")
      vehicleAB = vehiclePeripheral.name!
      print(vehiclePeripheral ?? "")
        vehiclePeripheral.discoverServices([CBUUID(string: "2c00")])
    }
    



    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
          print(service)
          peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
      guard let characteristics = service.characteristics else { return }
      for characteristic in characteristics {
        print(characteristic)
        vehicleCharacteristic = characteristic
        connectedToVehicle = true
        self.vinLabel.text = vehiclePeripheral.name
        vehicleAB = vehiclePeripheral.name!
        
        
      }
    }
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print(peripheral)
        centralManager.cancelPeripheralConnection(peripheral)
        connectedToVehicle = false
        self.vinLabel.text = "Connecting..."
        centralManager.scanForPeripherals(withServices: services)
        
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        vehicleAB = "disconnected"
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(peripheral)
    }
}


class ViewController: UIViewController, MenuControllerDelegate {

    var sideMenu: SideMenuNavigationController?
    let vehicleController = VehicleViewController()
    let passwordController = PasswordViewController()
    
    var centralManager: CBCentralManager!
    var vehiclePeripheral: CBPeripheral!
    var vehicleCharacteristic:CBCharacteristic!
    var cbPassword = "password"
    var connectedToVehicle = false
    var vehicleAB = "Not connected"
    let services = [CBUUID(string: "2c00")]
    let cmdchar = [CBUUID(string: "2c10")]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        vehicleController.mainview = self
        passwordController.mainview = self
        let menu = MenuController(with: SideMenuItem.allCases)

        menu.delegate = self

        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true

        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)

        addChildControllers()
    }

    private func addChildControllers() {
        addChild(passwordController)
        addChild(vehicleController)
        view.addSubview(passwordController.view)
        view.addSubview(vehicleController.view)
        passwordController.view.frame = view.bounds
        vehicleController.view.frame = view.bounds
        passwordController.didMove(toParent: self)
        vehicleController.didMove(toParent: self)
        passwordController.view.isHidden = true
        vehicleController.view.isHidden = true
    }

    @IBAction func didTapMenuButton() {
        present(sideMenu!, animated: true)
    }

    func didSelectMenuItem(named: SideMenuItem) {
        sideMenu?.dismiss(animated: true, completion: nil)

        title = named.rawValue
        switch named {
        case .vehicle:
            passwordController.view.isHidden = true
            vehicleController.view.isHidden = false
        case .password:
            passwordController.view.isHidden = false
            vehicleController.view.isHidden = true
        case .home:
            passwordController.view.isHidden = true
            vehicleController.view.isHidden = true
        }

    }
    @IBAction func didTapMenu() {
        present(sideMenu!, animated: true)
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var vinLabel: UILabel!
    func someFunction() {
        
    }
    
    var enabled = false
    
    @IBAction func didTapScooter(sender: UIButton) {
        
        let on_image = UIImage(named: "on")
        let off_image = UIImage(named: "off")
        
        if !enabled {
            
            if connectedToVehicle {
                cbPassword = passwordController.passwordCB
                passwordController.updatePass()
            vehiclePeripheral.writeValue("AT+BKSCT=\(cbPassword),0$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
                sender.setImage(on_image, for: .normal)
                enabled = true
                print("Vehicle unlocked.")
            } else {
                let alert = UIAlertController(title: "Vehicle not connected!", message: "Please make sure your Vehicle is working.", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        else if enabled {
            
            if connectedToVehicle {
                sender.setImage(off_image, for: .normal)
                enabled = false
                print("Vehicle locked")
                cbPassword = passwordController.passwordCB
                passwordController.updatePass()
                vehiclePeripheral.writeValue("AT+BKSCT=\(cbPassword),1$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
                }  else {
                    let alert = UIAlertController(title: "Vehicle not connected!", message: "Please make sure your Vehicle is working.", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    @IBOutlet weak var currentLabel: UILabel!
    @IBAction func didSlideSpeed(sender: UISlider) {
        
        
        if connectedToVehicle {
            let sliderThumb = UIImage(named: "arrow.left.and.right.square.fill")
            sender.setThumbImage(sliderThumb, for: UIControl.State.normal)
            let speedInt:Int = Int(sender.value)
            print("Speed \(speedInt)")
            currentLabel.text = "\(speedInt) KM/H"
            sender.isContinuous = false
            cbPassword = passwordController.passwordCB
            passwordController.updatePass()
            vehiclePeripheral.writeValue("AT+BKECP=\(cbPassword),1,\(speedInt),1,$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            
        }  else {
            let alert = UIAlertController(title: "Vehicle not connected!", message: "Please make sure your Vehicle is working.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}



