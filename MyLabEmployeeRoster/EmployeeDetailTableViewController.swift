//
//  EmployeeDetailTableViewController.swift
//  MyLabEmployeeRoster
//
//  Created by 曹家瑋 on 2023/10/15.
//

import UIKit

// MARK: - EmployeeDetailTableViewControllerDelegate Protocol

// 定義一個 protocol 來通知 delegate 有關員工資訊的儲存事件。
protocol EmployeeDetailTableViewControllerDelegate: AnyObject {
    func employeeDetailTableViewController(_ controller: EmployeeDetailTableViewController, didSave employee: Employee)
}


// MARK: - EmployeeDetailTableViewController

class EmployeeDetailTableViewController: UITableViewController {

    
    // MARK: - Outlets

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var employeeTypeLabel: UILabel!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    
    
    // MARK: - Properties

    // 一個 weak 的 delegate 變數，防止循環引用並提供一個通道通知其他物件有關事件。
    weak var delegate: EmployeeDetailTableViewControllerDelegate?
    // 用於儲存和顯示員工資訊
    var employee: Employee?
    // 儲存選擇的員工類型
    var employeeType: EmployeeType?
    
    
    // 每當isEditingBirthday的值變動時，調用tableView.beginUpdates()和tableView.endUpdates()來更新表格視圖
    var isEditingBirthday: Bool = false {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
        updateSaveButtonState()
    }
    
    // MARK: - Actions
    
    // “儲存”按鈕
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // 確保在保存員工資料時，將用戶選擇的員工類型也一起保存
        guard let name = nameTextField.text,
                let employeeType = employeeType else { return }
        
        // 創建一個新的員工物件並通知 delegate。
        // 使用日期選擇器上的日期。
        let employee = Employee(name: name, dateOfBirth: dobDatePicker.date, employeeType: employeeType)
        delegate?.employeeDetailTableViewController(self, didSave: employee)
    }

    // “取消”按鈕
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        // 將員工變數設置為nil，清除當前視圖的員工資訊
        employee = nil
    }
    
    // 當 nameTextField 的內容變更時呼叫的方法。
    @IBAction func nameTextFieldDidChange(_ sender: UITextField) {
        // 檢查並更新"儲存"按鈕的啟用狀態。
        updateSaveButtonState()
    }
    
    // （Event）設定為（Value Changed）以便在日期選擇器的日期改變時調用這個方法。
    @IBAction func dobPickerValueChanged(_ sender: UIDatePicker) {
        // 將 dobLabel 設定為新選擇的日期。
        dobLabel.text = dobDatePicker.date.formatted(date: .abbreviated, time: .omitted)
    }
    
    // MARK: - Methods
    
    // 更新視圖以顯示員工資訊
    func updateView() {
        if let employee = employee {
            // 如果員工變數有值，顯示員工的名字和其他資訊。
            navigationItem.title = employee.name
            nameTextField.text = employee.name
            
            dobLabel.text = employee.dateOfBirth.formatted(date: .abbreviated, time: .omitted)
            dobLabel.textColor = .label
            employeeTypeLabel.text = employee.employeeType.description
            employeeTypeLabel.textColor = .label
        } else {
            // 如果員工變數沒有值，顯示“New Employee”作為標題。
            navigationItem.title = "New Employee"
            //
            prepareDOBPicker()
        }
    }
    
    /// 用來更新"儲存"按鈕的啟用狀態。
    private func updateSaveButtonState() {
        // 如果 nameTextField 有內容、員工類型有選擇時則啟用"儲存"按鈕。否則禁用它。
        let shouldEnableSaveButton = nameTextField.text?.isEmpty == false && employeeType != nil
        saveBarButtonItem.isEnabled = shouldEnableSaveButton
    }
    
    /// 設定出生日期選擇器（date picker）的預設值
    private func prepareDOBPicker() {
        // 獲取當前的年、月、日元件
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        // 確保dateComponents使用當前的日曆計算日期
        dateComponents.calendar = Calendar.current
        
        // 檢查當前年份是否可用
        guard let currentYear = dateComponents.year else { return }
        // 設置目標月份和日期
        dateComponents.month = 12
        dateComponents.day = 2
        // 設置目標年份為當前年份減去40，即預設出生日期為40年前的12月2日
        dateComponents.year = (currentYear - 40)
        // 如果計算的日期可用，設置為date picker的預設值；否則使用當前日期作為預設值
        dobDatePicker.date = dateComponents.date ?? Date()
    }
    
    
    // MARK: - Navigation
    
    // 當轉場到 EmployeeTypeTableViewController 時，我們通過使用 @IBSegueAction 方法來初始化並設定代理
    @IBSegueAction func showEmployeeTypes(_ coder: NSCoder) -> EmployeeTypeTableViewController? {
        // 使用傳入的 coder創建一個 EmployeeTypeTableViewController 的實例
        let typeController = EmployeeTypeTableViewController(coder: coder)
        
        // 將當前的對象（self）設定為它的代理，意味著當 EmployeeTypeTableViewController 用戶選擇一個員工類型時，
        // 它將通知（通過 delegate 方法）並將相關數據傳遞給這個代理對象（此處是 self）
        typeController?.delegate = self
        
        // 將創建的 typeController 返回，以便於當 Segue 過渡執行時將其設定為目標視圖控制器
        return typeController
    }
    
    
    // MARK: - table View Delegate
    // 設定每一行的高度
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 對應的 indexPath 等於「日期選擇器的索引路徑」且isEditingBirthday的值為false 隱藏該Cell
        if indexPath == IndexPath(row: 2, section: 0) && isEditingBirthday == false {
            return 0
        } else {
            // 反之，讓Cell自動調整大小
            return UITableView.automaticDimension
        }
    }
    
    // 選擇生日Cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消該行的選擇狀態
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 選擇的行對應的索引路徑等於生日標籤（dobLabel）
        if indexPath == IndexPath(row: 1, section: 0) {
            // 切換isEditingBirthday的值，藉此開起隱藏datepicker
            isEditingBirthday.toggle()
            dobLabel.textColor = .label
            // 使用datepicker的日期來更新dobLabel的文本。
            dobLabel.text = dobDatePicker.date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}


// MARK: - EmployeeTypeTableViewControllerDelegate

// 擴展 EmployeeDetailTableViewController 以遵守 EmployeeTypeTableViewControllerDelegate 協議
extension EmployeeDetailTableViewController: EmployeeTypeTableViewControllerDelegate {
    
    // 實現協議中的方法，當員工類型被選擇時此方法會被調用
    func employeeTypeTableViewController(_ controller: EmployeeTypeTableViewController, didSelect employeeType: EmployeeType) {
        
        // 更新此控制器的 employeeType 屬性
        self.employeeType = employeeType
        
        // 更新 UI 來顯示被選擇的員工類型的描述
        employeeTypeLabel.textColor = .label
        employeeTypeLabel.text = employeeType.description
        
        // 更新儲存按鈕的狀態（確認所有必要欄位都已被填寫，才允許儲存）
        updateSaveButtonState()
    }
}
