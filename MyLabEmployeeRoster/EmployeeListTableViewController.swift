//
//  EmployeeListTableViewController.swift
//  MyLabEmployeeRoster
//
//  Created by 曹家瑋 on 2023/10/15.
//

import UIKit

class EmployeeListTableViewController: UITableViewController {

    // MARK: - Properties

    // 存儲重用的cell的identifier。
    struct PropertyKeys {
        static let employeeCell = "EmployeeCell"
    }
    
    // 用來存儲員工資料的陣列。
    var employees: [Employee] = []
    

    // MARK: - Table view data source

    // 返回表格視圖的行數，即員工數量。
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }

    // 配置每一行的cell，顯示對應員工的名字和員工類型。
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.employeeCell, for: indexPath)

        let employee = employees[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = employee.name
        content.secondaryText = employee.employeeType.description
        cell.contentConfiguration = content

        return cell
    }
    
    // 實現刪除功能。當用戶嘗試刪除一行時，從數據源中移除對應的員工，並以動畫效果更新視圖。
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            employees.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // MARK: - Navigation

    // 當進行segue跳轉時，配置目標視圖控制器，即EmployeeDetailTableViewController。
    @IBSegueAction func showEmployeeDetail(_ coder: NSCoder, sender: Any?) -> EmployeeDetailTableViewController? {
        // 創建並配置目標視圖控制器。
        let detailViewController = EmployeeDetailTableViewController(coder: coder)
        detailViewController?.delegate = self
        
        // 確定是否是從一個cell觸發的segue，如果是，將對應員工的資料傳遞給目標視圖控制器。
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell)
        else {
            return detailViewController
        }
        
        // 從員工陣列中擷取出對應 indexPath 的員工數據。
        let employee = employees[indexPath.row]
        // 將找到的 employee 對象傳遞給 detailViewController 以顯示其數據。
        detailViewController?.employee = employee
        
        return detailViewController
    }
    
    // 返回至此視圖控制器並刷新數據
    @IBAction func unwindToEmployeeList(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
}


// MARK: - EmployeeDetailTableViewControllerDelegate

// 實現EmployeeDetailTableViewControllerDelegate協議，以處理員工資料的儲存事件。
extension EmployeeListTableViewController: EmployeeDetailTableViewControllerDelegate {
    
    func employeeDetailTableViewController(_ controller: EmployeeDetailTableViewController, didSave employee: Employee) {
        
        // 確定是否是編輯已存在的員工，如果是，更新對應的資料；如果不是，添加到員工數組中。
        if let indexPath = tableView.indexPathForSelectedRow {
            employees.remove(at: indexPath.row)
            employees.insert(employee, at: indexPath.row)
        } else {
            employees.append(employee)
        }
        
        // 更新表格視圖並返回到前一視圖。
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }

}

