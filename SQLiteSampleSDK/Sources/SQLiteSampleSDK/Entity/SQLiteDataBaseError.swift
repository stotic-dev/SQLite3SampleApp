//
//  SQLiteDataBaseError.swift
//  
//
//  Created by 佐藤汰一 on 2024/07/15.
//

enum SQLiteDataBaseError: Error {
    
    case notOpenDatabaseYet
    case failedOpenDatabase
    case invalidSql(String)
    case failedCreateTable(String)
    case failedInsertQuery(String, [SQLiteBindType])
    case failedSelectQuery(String, [SQLiteBindType])
    case failedDeleteQuery(String, [SQLiteBindType])
}
