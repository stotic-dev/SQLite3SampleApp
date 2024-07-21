//
//  DataBase.swift
//
//
//  Created by 佐藤汰一 on 2024/07/14.
//

import Foundation
import SQLite3

/// SQLite3のDB操作を行うクラス
/// - Attention: はじめにopenDbでDBファイルを開けないとエラーが発生します
@globalActor
public actor DataBase {
    
    /// DataBaseを使用する場合はこのシングルトンからアクセスする
    public static let shared = DataBase()
    
    // DBファイル名
    private static let dbFileName = "sample.db"
    
    // DB
    private var dbPointer: OpaquePointer?
    
    /// DBを開く
    public func openDb() throws {
        
        print("In openDb \(Thread.current.debugDescription)")
        
        guard let dbPath = getDbFilePath(),
        sqlite3_open(dbPath, &dbPointer) == SQLITE_OK else {
            
            throw SQLiteDataBaseError.failedOpenDatabase
        }
    }
    
    /// テーブルを作成する
    /// - Parameter sqlString: テーブル作成SQL文字列
    public func createDb(_ sqlString: String) throws {
        
        print("In createDb \(Thread.current.debugDescription)")
        let dbPointer = try getDbPointer()
        let sql = try SqlModel(db: dbPointer, sqlString: sqlString)
        
        defer {
            
            sqlite3_finalize(sql.statement)
        }
        
        guard sqlite3_step(sql.statement) == SQLITE_DONE else { throw SQLiteDataBaseError.failedCreateTable(sql.sqlString) }
    }
    
    /// インサートする
    /// - Parameters:
    ///   - sqlString: insertのSQL文
    ///   - binds: SQLの?部分にバインドする型情報とその値
    public func insert(_ sqlString: String, binds: [SQLiteBindType]) throws {
        
        print("In insert \(Thread.current.debugDescription)")
        let dbPointer = try getDbPointer()
        let sql = try SqlModel(db: dbPointer, sqlString: sqlString, binds: binds)
        
        defer {
            
            sqlite3_finalize(sql.statement)
        }
        
        guard sqlite3_step(sql.statement) == SQLITE_DONE else { throw SQLiteDataBaseError.failedInsertQuery(sqlString, binds) }
    }
    
    /// セレクトする
    /// - Parameters:
    ///   - query: selectのquery情報
    /// - Returns: セレクト結果のリスト
    public func select<T>(_ query: SQLiteSelectQuery) throws -> [T] where T: SQLiteRecordEncodable {
        
        print("In select \(Thread.current.debugDescription)")
        let dbPointer = try getDbPointer()
        let sql = try SqlModel(db: dbPointer, sqlString: query.sql, binds: query.bindList)
        
        defer {
            
            sqlite3_finalize(sql.statement)
        }
        
        var results = [T]()
        
        while sqlite3_step(sql.statement) == SQLITE_ROW {
            
            var resultValues = [SQLiteBindType]()
            query.selectTypes.enumerated().forEach {
                
                switch $1 {
                    
                case .string:
                    guard let textCol = sqlite3_column_text(sql.statement, Int32($0)) else { return }
                    resultValues.append(.string(NSString(string: String(cString: textCol))))
                case .int32:
                    resultValues.append(.int32(sqlite3_column_int(sql.statement, Int32($0))))
                }
            }
            
            if let resultRecord = T(resultValues) { results.append(resultRecord) }
        }
        
        return results
    }
    
    /// デリートする
    /// - Parameters:
    ///   - sqlString: deleteのSQL文
    ///   - binds: SQLの?部分にバインドする型情報とその値
    public func delete(_ sqlString: String, binds: [SQLiteBindType]) throws {
        
        print("In delete \(Thread.current.debugDescription)")
        let dbPointer = try getDbPointer()
        let sql = try SqlModel(db: dbPointer, sqlString: sqlString, binds: binds)
        
        defer {
            
            sqlite3_finalize(sql.statement)
        }
        
        guard sqlite3_step(sql.statement) == SQLITE_DONE else { throw SQLiteDataBaseError.failedDeleteQuery(sqlString, binds) }
    }
}

private extension DataBase {
    
    func getDbFilePath() -> String? {
        
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { 
            
            return nil
        }
        
        var filePath = documentDir
        filePath.append(component: Self.dbFileName, directoryHint: .notDirectory)
        
        print("dbFileName = \(filePath)")
        
        return filePath.path()
    }
    
    func getDbPointer() throws -> OpaquePointer {
        
        guard let dbPointer = dbPointer else { throw SQLiteDataBaseError.notOpenDatabaseYet }
        return dbPointer
    }
}
