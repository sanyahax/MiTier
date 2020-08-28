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

class ViewController: UIViewController {

    
    
    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        }
        else if enabled {
            sender.setImage(off_image, for: .normal)
            enabled = false
        }
        
    }
    @IBAction func didSlideSpeed(sender: UISlider) {
        let sliderThumb = UIImage(named: "arrow.left.and.right.square.fill")
        sender.setThumbImage(sliderThumb, for: UIControl.State.normal)
        var speedInt:Int = Int(sender.value)
           print("Speed \(speedInt)")
    }
}
class MenuListController: UITableViewController {
    var items = ["Change Password"]
        
    let darkColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    
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
        cell.textLabel?.textColor = .white
        
        cell.backgroundColor = darkColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


