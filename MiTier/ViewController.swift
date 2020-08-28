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
        let services = [CBUUID(string: "2c00")]
        let cmdchar = [CBUUID(string: "2c10")]
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
        }
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        vehiclePeripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(vehiclePeripheral)
        vehiclePeripheral.delegate = self
        print(vehiclePeripheral)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("Connected!")
      print(vehiclePeripheral)
        vehiclePeripheral.discoverServices([CBUUID(string: "2c00")])
    }
    



    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
          print(service)
          print(service.characteristics ?? "characteristics are nil")
          peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
      guard let characteristics = service.characteristics else { return }
      for characteristic in characteristics {
        print(characteristic)
        vehicleCharacteristic = characteristic
        
      }
    }
}


class ViewController: UIViewController {

    
    var centralManager: CBCentralManager!
    var vehiclePeripheral: CBPeripheral!
    var vehicleCharacteristic:CBCharacteristic!
    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        
        menu = SideMenuNavigationController(rootViewController: MenuListController())
        menu?.leftSide = true
        
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }

    @IBAction func didTapMenu() {
        present(menu!, animated: true)
    }
    
    var enabled = false
    
    @IBAction func didTapScooter(sender: UIButton) {
        
        let on_image = UIImage(named: "on")
        let off_image = UIImage(named: "off")
        
        if !enabled {
            sender.setImage(on_image, for: .normal)
            enabled = true
            print("Vehicle unlocked.")
            vehiclePeripheral.writeValue("AT+BKSCT=PASS123,1$,r,n".data(using: String.Encoding.utf8)!, for: vehicleCharacteristic, type: CBCharacteristicWriteType.withResponse)
            
        }
        else if enabled {
            sender.setImage(off_image, for: .normal)
            enabled = false
            print("Vehicle locked")
        }
        
    }
    @IBAction func didSlideSpeed(sender: UISlider) {
        let sliderThumb = UIImage(named: "arrow.left.and.right.square.fill")
        sender.setThumbImage(sliderThumb, for: UIControl.State.normal)
        let speedInt:Int = Int(sender.value)
           print("Speed \(speedInt)")
    }
}
class MenuListController: UITableViewController {
    var items = ["Change Password"]
        
    let darkColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    let tierColor = UIColor(red: 106/255.0, green: 209/255.0, blue: 170/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = darkColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.highlightedTextColor = .white
        
        self.tableView.separatorStyle = .none
        self.tableView.isScrollEnabled = false
        self.tableView.tableHeaderView?.backgroundColor = tierColor
        cell.backgroundColor = tierColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


