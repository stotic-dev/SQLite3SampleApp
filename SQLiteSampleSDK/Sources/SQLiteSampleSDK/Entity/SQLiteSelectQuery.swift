//
//  SQLIiteSelectQuery.swift
//
//
//  Created by 佐藤汰一 on 2024/07/20.
//

public struct SQLiteSelectQuery {
    
    public init(sql: String, bindList: [SQLiteBindType], selectTypes: [SQLiteBindType]) {
        
        self.sql = sql
        self.bindList = bindList
        self.selectTypes = selectTypes
    }
    
    /// SQLのSELECT文
    let sql: String
    /// SQLのパラメータバインド
    let bindList: [SQLiteBindType]
    /// SELECT結果の戻り値型
    let selectTypes: [SQLiteBindType]
}
