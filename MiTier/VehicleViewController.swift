//
//  VehicleViewController.swift
//  MiTier
//
//  Created by Alexander Klemt on 29.08.20.
//  Copyright © 2020 Arendai. All rights reserved.
//

import UIKit

class VehicleViewController: UIViewController {
    
    var mainview:ViewController?
     
    override func viewDidLoad() {
        super.viewDidLoad()
        let vehicleAB = mainview!.vehicleAB
        self.view.backgroundColor = .systemGray5
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 600, height: 21))
        label.center = CGPoint(x: 50, y: 50)
        label.textAlignment = .right
        label.text = "Serial Number: \(vehicleAB)"
    }
    

}
