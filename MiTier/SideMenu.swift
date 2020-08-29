//
//  SideMenu.swift
//  MiTier
//
//  Created by Alexander Klemt on 29.08.20.
//  Copyright © 2020 Arendai. All rights reserved.
//


import Foundation
import UIKit

protocol MenuControllerDelegate {
    func didSelectMenuItem(named: SideMenuItem)
}

enum SideMenuItem: String, CaseIterable {
    case home = "Vehicle"
    case vehicle = "Vehicle Data"
    case password = "Change Password"
    
}

class MenuController: UITableViewController {

    public var delegate: MenuControllerDelegate?
    let darkColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    let tierColor = UIColor(red: 106/255.0, green: 209/255.0, blue: 170/255.0, alpha: 1)
    private let menuItems: [SideMenuItem]
    private let color = UIColor(red: 33/255.0,
                                green: 33/255.0,
                                blue: 33/255.0,
                                alpha: 1)

    init(with menuItems: [SideMenuItem]) {
        self.menuItems = menuItems
        super.init(nibName: nil, bundle: nil)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = tierColor
        view.backgroundColor = darkColor
    }

    // Table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row].rawValue
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.highlightedTextColor = tierColor
        self.tableView.separatorStyle = .none
        self.tableView.isScrollEnabled = false
        self.tableView.tableHeaderView?.backgroundColor = tierColor
        cell.backgroundColor = tierColor
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Relay to delegate about menu item selection
        let selectedItem = menuItems[indexPath.row]
        delegate?.didSelectMenuItem(named: selectedItem)
        self.view.endEditing(true)
    }

}
