//
//  SQLiteBindType.swift
//
//
//  Created by 佐藤汰一 on 2024/07/15.
//

import Foundation

/// SQLにバインドする値の型を表すenum
public enum SQLiteBindType {
    
    case string(NSString)
    case int32(Int32)
}
