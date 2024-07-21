//
//  SqlModel.swift
//
//
//  Created by 佐藤汰一 on 2024/07/15.
//

import SQLite3

struct SqlModel {
    
    let sqlString: String
    private(set) var statement: OpaquePointer?
    
    init(db: OpaquePointer, sqlString: String) throws {
        
        self.sqlString = sqlString
        
        guard sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) == SQLITE_OK else { throw SQLiteDataBaseError.invalidSql(sqlString) }
    }
    
    init(db: OpaquePointer, sqlString: String, binds: [SQLiteBindType]) throws {
        
        self.sqlString = sqlString
        
        guard sqlite3_prepare_v2(db, sqlString, -1, &statement, nil) == SQLITE_OK else { throw SQLiteDataBaseError.invalidSql(sqlString) }
        binds.enumerated().forEach {
            
            let bindIndex = Int32($0 + 1)
            switch $1 {
                
            case .string(let value):
                sqlite3_bind_text(statement, bindIndex, value.utf8String, -1, nil)
                
            case .int32(let value):
                sqlite3_bind_int(statement, bindIndex, value)
            }
        }
    }
}
