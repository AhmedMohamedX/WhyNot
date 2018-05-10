//
//  MenuViewController.swift
//  SideMenuu
//
//  Created by Beyram on 11/3/17.
//  Copyright © 2017 Beyram. All rights reserved.
//


import UIKit
import SideMenu

protocol MenuViewControllerDelegate: class {
    
    func menu(_ menu: MenuViewController, didSelectItemAt index: Int, at point: CGPoint)
    func menuDidCancel(_ menu: MenuViewController)
}

class MenuViewController: UITableViewController {
    
    weak var delegate: MenuViewControllerDelegate?
    var selectedItem = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let indexPath = IndexPath(row: selectedItem, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        tableView.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)

    }
}

extension MenuViewController {
    
    @IBAction fileprivate func dismissMenu() {
        delegate?.menuDidCancel(self)
    }
}

//MARK: Menu protocol
extension MenuViewController: Menu {
    
    var menuItems: [UIView] {
        return [tableView.tableHeaderView!] + tableView.visibleCells
    }
}

extension MenuViewController {
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath == tableView.indexPathForSelectedRow ? nil : indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rect = tableView.rectForRow(at: indexPath)
        var point = CGPoint(x: rect.midX, y: rect.midY)
        point = tableView.convert(point, to: nil)
        delegate?.menu(self, didSelectItemAt: indexPath.row, at: point)
    }
}

