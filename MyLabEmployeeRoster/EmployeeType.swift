//
//  EmployeeType.swift
//  MyLabEmployeeRoster
//
//  Created by 曹家瑋 on 2023/10/15.
//

import Foundation

struct Employee {
    // 員工姓名
    var name: String
    // 生日
    var dateOfBirth: Date
    // 員工的類型
    var employeeType: EmployeeType
}

// 遵從(CaseIterable)和(CustomStringConvertible)兩個協議
enum EmployeeType: CaseIterable, CustomStringConvertible {
    // 員工類型
    case exempt
    case nonExempt
    case partTime
    
    // 使用 'description' 屬性來提供每個員工類型的名稱。
    var description: String {
        switch self {
        case .exempt:
            return "Exempt Full Time"
        case .nonExempt:
            return "Non-exempt Full Time"
        case .partTime:
            return "Part Time "
        }
    }
}
