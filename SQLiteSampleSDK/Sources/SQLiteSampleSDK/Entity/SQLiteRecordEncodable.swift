//
//  SQLiteRecordEncodable.swift
//
//
//  Created by 佐藤汰一 on 2024/07/15.
//

public protocol SQLiteRecordEncodable {
    
    init?(_ result: [SQLiteBindType])
}
