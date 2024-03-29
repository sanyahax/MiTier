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
import IntentsUI
import GDGauge

extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
}
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
            connectedToVehicle = false
        case .resetting:
            print("CB.state is reset")
            connectedToVehicle = false
        case .unsupported:
            print("CB.state is unsupported.")
            connectedToVehicle = false
        case .unauthorized:
            print("CB.state is unauth")
            connectedToVehicle = false
        case .poweredOff:
            print("CB.state is off")
            connectedToVehicle = false
            vinLabel.text = "BLE off"
        case .poweredOn:
            print("CB.state is on")
            centralManager.scanForPeripherals(withServices: nil)
            vinLabel.text = "Connecting..."
            
        @unknown default:
            print("default")
        }
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        vehiclePeripheral = peripheral
        centralManager.stopScan()
        if(serialTextField.text!.isEmpty) {
            if vehiclePeripheral.name!.contains("AB1") { // <== CHANGE TO HARDCODE
                centralManager.connect(vehiclePeripheral)
            }
        } else {
            if vehiclePeripheral.name!.contains(serialTextField.text!) {
                centralManager.connect(vehiclePeripheral)
                if(serialTextField.text!.contains("ES200D")) {
                    g0Var = true
                }
            }
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
            if(g0Var == true) {
                let uuidlist = ["2c01","2c03"]
                peripheral.discoverCharacteristics([CBUUID(string: "2c01")], for: service)
            } else {
                peripheral.discoverCharacteristics([CBUUID(string: "2c01")], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
      for characteristic in characteristics {
        print(characteristic)
        if(characteristic.properties.contains(CBCharacteristicProperties.write)) {
            let xdmaga = characteristic
            vehicleCharacteristic = xdmaga
        }
       // vehiclePeripheral.setNotifyValue(true, for: vehicleCharacteristic)
        connectedToVehicle = true
        self.vinLabel.text = vehiclePeripheral.name
        vehicleAB = vehiclePeripheral.name!
        print(vehicleCharacteristic!)
        //vehiclePeripheral.writeValue("AT+BKINF=\(passwordController.passwordCB),".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        //vehiclePeripheral.writeValue("1$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        
        
        
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
        connectedToVehicle = false
        self.vinLabel.text = "Connecting..."
        centralManager.scanForPeripherals(withServices: services)
        if(serialTextField.text!.isEmpty) {
            if vehiclePeripheral.name!.contains("AB1") { // <== CHANGE TO HARDCODE
                centralManager.connect(vehiclePeripheral)
            }
        } else {
            if vehiclePeripheral.name!.contains(serialTextField.text!) {
                centralManager.connect(vehiclePeripheral)
            }
        }
        scooterTapButton.setImage(UIImage(named: "off"), for: .normal)
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let string = String(bytes: characteristic.value!, encoding: .utf8) {
            //print(string)
            if(string.contains("+ACK:BKINF")) {
                let status = string.components(separatedBy: ",")
                print("Locked: \(status[1])")
                print("Speed: \(status[2])")
                speednow = Int(Double(status[2])!)
                if(status[1] == "1") {
                    enabled = false
                }
                if(status[1] == "0") {
                    enabled = true
                }
            }
            if(string.contains("$")) {
                
                let status = string.components(separatedBy: ",")
                if(status.endIndex > 2) {
                    if(status[4] == "1") {
                        hheadlightswitch.setOn(true, animated: false)
                    } else if(status[4] == "0"){
                        hheadlightswitch.setOn(false, animated: false)
                    }
                    battery = status[3]
                    let totalrange2 = round(Double(status[1])!) ?? 100000.0
                    totalrange = String(totalrange2-100000)
                    print("Battery: \(battery)")
                    print("Total Range: \(totalrange)")
                }
            }
        } else {
            print("not a valid UTF-8 sequence")
        }
    
        
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //print(characteristic)
        //print(error.debugDescription)
        //print(characteristic.value)
        //print(characteristic.debugDescription)
    }
}


class ViewController: UIViewController, MenuControllerDelegate {

    var sideMenu: SideMenuNavigationController?
    let vehicleController = VehicleViewController()
    let passwordController = PasswordViewController()
    
    
    var centralManager: CBCentralManager!
    var vehiclePeripheral: CBPeripheral!
    var vehicleCharacteristic:CBCharacteristic!
    var cbPassword = ""
    var vehicleDataINF = ""
    var lockStatus = true
    var battery = ""
    var totalrange = ""
    var laststatus = false
    var connectedToVehicle = false
    var vehicleAB = "Not connected"
    var speedkmh = "1"
    var speednow = 0
    let services = [CBUUID(string: "00002c00-0000-1000-8000-00805f9b34fb")]
    let cmdchar = [CBUUID(string: "00002c01-0000-1000-8000-00805f9b34fb")]
    let defaults = UserDefaults.standard
    var headlight = false
    var g0Var = false
    var sportmode = false
    let defaults1 = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        view.snapshotView(afterScreenUpdates: true)
        vehicleController.mainview = self
        passwordController.mainview = self
        let menu = MenuController(with: SideMenuItem.allCases)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        menu.delegate = self
        if defaults.bool(forKey: "sportmode") == true {
            sportswitchc.setOn(true, animated: false)
        } else {
            sportswitchc.setOn(false, animated: false)
        }
        if defaults.bool(forKey: "headlight") == true {
            hheadlightswitch.setOn(true, animated: false)
        } else {
            hheadlightswitch.setOn(false, animated: false)
        }
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true

        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)

        addChildControllers()
        view.addGestureRecognizer(tap)
        sliderToSetValue.value = defaults.float(forKey: "SliderValue")
        currentLabel.text = "\(defaults.integer(forKey: "SliderValue"))KM/H"
    
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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

    @IBOutlet weak var scooterTapButton: UIButton!
    @IBAction func didTapMenuButton() {
        present(sideMenu!, animated: true)
    }
    
    @IBOutlet weak var sportswitchc: UISwitch!
    @IBOutlet weak var hheadlightswitch: UISwitch!
    @IBOutlet weak var sport2: UISwitch!
    @IBAction func sportSwitchh(_ sender: UISwitch) {
        if sender.isOn {
            vehiclePeripheral.writeValue("AT+BKECP=\(cbPassword),".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            vehiclePeripheral.writeValue("1,,1,$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            defaults.setValue(true, forKey: "sportmode")
            sportmode = true
        } else if !sender.isOn{
            vehiclePeripheral.writeValue("AT+BKECP=\(cbPassword),".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            vehiclePeripheral.writeValue("1,,0,$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            defaults.setValue(false, forKey: "sportmode")
        }
    }
    @IBOutlet weak var sportswitchc2: UISwitch!
    @IBAction func sportSwitchh2(_ sender: UISwitch) {
        if sender.isOn {
            vehiclePeripheral.writeValue("AT+BKECP=\(cbPassword),".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            vehiclePeripheral.writeValue("1,,,0$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            defaults.setValue(true, forKey: "sportmode")
            sportmode = true
        } else if !sender.isOn{
            vehiclePeripheral.writeValue("AT+BKECP=\(cbPassword),".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            vehiclePeripheral.writeValue("1,,,1$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            defaults.setValue(false, forKey: "sportmode")
        }
    }
    @IBAction func lightSwitchh(_ sender: UISwitch) {
        if sender.isOn {
            self.vehiclePeripheral.writeValue("AT+BKLED=\(cbPassword),".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            self.vehiclePeripheral.writeValue("0,1$\r\n".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            defaults.setValue(true, forKey: "headlight")
        } else if !sender.isOn{
            self.vehiclePeripheral.writeValue("AT+BKLED=\(cbPassword),".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            self.vehiclePeripheral.writeValue("0,0$\r\n".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            defaults.setValue(false, forKey: "headlight")
        }
    }
    func speedFunc() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            print(self.speednow)
            if self.speednow > 30 {
                self.vehiclePeripheral.writeValue("AT+BKWRN=\(self.cbPassword),".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
                self.vehiclePeripheral.writeValue("1$\r\n".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            } else {
                print("succ")
            }
        }
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
    
    @IBOutlet weak var serialTextField: UITextField!
    
    @IBAction func changeValueSerial(_ sender: UITextField) {
        if sender.endEditing(true) {
            centralManager.cancelPeripheralConnection(vehiclePeripheral)
            centralManager.scanForPeripherals(withServices: services)
            if vehiclePeripheral.name!.contains(serialTextField.text!) {
                centralManager.connect(vehiclePeripheral)
            }
        }
    }
    var enabled = false
    
    @IBAction func didTapWRN(sender: UIButton) {
        if connectedToVehicle {
            cbPassword = passwordController.passwordCB
            passwordController.updatePass()
            laststatus = true
            vehiclePeripheral.writeValue("AT+BKWRN=\(cbPassword),".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            vehiclePeripheral.writeValue("1$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            enabled = true
            print("Vehicle blink.")
        } else {
            let alert = UIAlertController(title: "Vehicle not connected!", message: "Please make sure your Vehicle is working.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func didTapScooter(sender: UIButton) {
        
        let on_image = UIImage(named: "on")
        let off_image = UIImage(named: "off")
        
        if !enabled {
            
            if connectedToVehicle {
                cbPassword = passwordController.passwordCB
                passwordController.updatePass()
                vehiclePeripheral.writeValue("AT+BKSCT=\(cbPassword),".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
                vehiclePeripheral.writeValue("0$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                sender.setImage(on_image, for: .normal)
                enabled = true
                print("Vehicle unlocked.")
                if(hheadlightswitch.isOn) {
                    print("nice")
                    
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.vehiclePeripheral.writeValue("AT+BKLED=\(self.cbPassword),".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
                        self.vehiclePeripheral.writeValue("0,0$\r\n".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                    }
                }
                
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
                vehiclePeripheral.writeValue("AT+BKSCT=\(cbPassword),".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                vehiclePeripheral.writeValue("1$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                if(hheadlightswitch.isOn) {
                    print("nice")
                    
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.vehiclePeripheral.writeValue("AT+BKLED=\(self.cbPassword),".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
                        self.vehiclePeripheral.writeValue("0,0$\r\n".data(using: String.Encoding.utf8)!, for: self.vehicleCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                    }
                    
                }
                }  else {
                    let alert = UIAlertController(title: "Vehicle not connected!", message: "Please make sure your Vehicle is working.", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    @IBOutlet weak var sliderToSetValue: UISlider!
    @IBOutlet weak var currentLabel: UILabel!
    @IBAction func didSlideSpeed(sender: UISlider) {
        
        
        if connectedToVehicle {
            let sliderThumb = UIImage(named: "icon")
            let sliderThumbHighlighted = UIImage(named: "iconhighlighted")
            
            sender.setThumbImage(sliderThumb!.scaleImage(toSize: CGSize(width: 10, height: 10)), for: UIControl.State.normal)
            sender.setThumbImage(sliderThumbHighlighted!.scaleImage(toSize: CGSize(width: 10, height: 10)), for: UIControl.State.highlighted)
            var speedInt:Int = Int(sender.value)
            if( speedInt == 0) {
                speedInt = 1
            }
            print("Speed \(speedInt)")
            speedkmh = String(speedInt)
            currentLabel.text = "\(speedInt) KM/H"
            sender.isContinuous = false
            cbPassword = passwordController.passwordCB
            passwordController.updatePass()
            
            defaults.set(speedInt, forKey: "SliderValue")
            
            vehiclePeripheral.writeValue("AT+BKECP=\(cbPassword),".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            vehiclePeripheral.writeValue("1,\(speedInt),,$\r\n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            
            
        }  else {
            let alert = UIAlertController(title: "Vehicle not connected!", message: "Please make sure your Vehicle is working.", preferredStyle: .alert)
            //self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
