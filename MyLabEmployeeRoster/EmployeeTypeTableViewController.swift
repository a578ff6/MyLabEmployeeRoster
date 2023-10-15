//
//  EmployeeTypeTableViewController.swift
//  MyLabEmployeeRoster
//
//  Created by 曹家瑋 on 2023/10/15.
//

import UIKit

// 希望當用戶在 EmployeeTypeTableViewController 中選擇了一個員工類型時，能將這個資訊通知給另一個畫面（前一個畫面，也就是EmployeeDetailTableViewController）。
// 這個協議定義了一個方法，允許 EmployeeTypeTableViewController 通知其代理選擇了一個員工類型。
protocol EmployeeTypeTableViewControllerDelegate: AnyObject {
    func employeeTypeTableViewController(_ controller: EmployeeTypeTableViewController, didSelect employeeType: EmployeeType)
}

class EmployeeTypeTableViewController: UITableViewController {

    //  用於提供與 dequeueReusableCell 相關的重用id。
    struct PropertyKeys {
        static let employeeType = "EmployeeType"
    }
    
    // 追蹤是否已經選擇了一個員工類型
    var employeeType: EmployeeType?
    
    // 這個可選代理將實現 EmployeeTypeTableViewControllerDelegate 協議的方法，以響應事件。
    var delegate: EmployeeTypeTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    // 設定 section。
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // 設定 tableView 的行數等於 EmployeeType 的數量。
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 這個陣列由 EmployeeType 上的 CaseIterable 協議生成
        return EmployeeType.allCases.count
    }

    // 設定和顯示Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取出 Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.employeeType, for: indexPath)
        
        // 從 allCases 中選取對應 indexPath.row 的員工類型。
        let type = EmployeeType.allCases[indexPath.row]
        
        // 配置單元格內容和樣式。
        var content = cell.defaultContentConfiguration()
        content.text = type.description
        cell.contentConfiguration = content
        
        // 根據當前行的「員工類型」是否與「選擇的員工類型」相匹配來設定單元格的 accessoryType。
        if employeeType == type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // 當用戶選中表格視圖中的一行時。
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 獲取選中的員工類型。
        let type = EmployeeType.allCases[indexPath.row]
        // 更新 employeeType 屬性的值。
        employeeType = type
        // 通知代理用戶選擇了一個新的員工類型。
        delegate?.employeeTypeTableViewController(self, didSelect: type)
        // 刷新表格視圖來更新 checkmark 的位置。
        tableView.reloadData()
    }


}
