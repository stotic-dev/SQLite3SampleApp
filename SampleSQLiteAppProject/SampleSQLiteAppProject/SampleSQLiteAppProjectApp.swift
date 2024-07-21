//
//  SampleSQLiteAppProjectApp.swift
//  SampleSQLiteAppProject
//
//  Created by 佐藤汰一 on 2024/07/14.
//

import SwiftUI
import SQLiteSampleSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private let createTableString = "CREATE TABLE MEMO_TABLE(id INTEGER PRIMARY KEY AUTOINCREMENT, memo TEXT NOT NULL);"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("didFinishLaunching")
        
        Task(priority: .high) { @DataBase in
            
            do {
                print("start open db.")
                try await DataBase.shared.openDb()
                print("end open db.")
                try await DataBase.shared.createDb(createTableString)
            }
            catch {
                
                print("Occured error \(error)")
            }
        }
        
        return true
    }
}

@main
struct SampleSQLiteAppProjectApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
