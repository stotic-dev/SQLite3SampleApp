//
//  ContentView.swift
//  SampleSQLiteAppProject
//
//  Created by 佐藤汰一 on 2024/07/14.
//

import SwiftUI
import SQLiteSampleSDK

struct Memo: Sendable, SQLiteRecordEncodable {
    
    let id: Int
    let memo: String
    
    init?(_ result: [SQLiteSampleSDK.SQLiteBindType]) {
        
        if let idResult = result.first,
           case .int32(let id) = idResult {
            
            self.id = Int(id)
        }
        else { return nil }
        
        if let memoResult = result.last,
           case .string(let memo) = memoResult {
            
            self.memo = String(memo)
        }
        else { return nil }
    }
    
    static func createAllSeletByIdQuery() -> SQLiteSelectQuery {
        
        return SQLiteSelectQuery(sql: "SELECT * FROM MEMO_TABLE;",
                                 bindList: [],
                                 selectTypes: [.int32(.zero), .string(.init())])
    }
    
    static func createSelectByMemoQuery(_ key: String) -> SQLiteSelectQuery {
        
        return SQLiteSelectQuery(sql: "SELECT * FROM MEMO_TABLE WHERE memo LIKE '%'||?||'%';",
                                 bindList: [.string(NSString(string: key))],
                                 selectTypes: [.int32(.zero), .string(.init())])
    }
}

struct ContentView: View {
    
    enum CurrentMode: String, CaseIterable {
        
        case viewer = "Viewer"
        case search = "Search"
        
        var executeButtonTitle: String {
            
            switch self {
                
            case .viewer:
                return "Add"
            case .search:
                return "Search"
            }
        }
    }
    
    @State var memo = ""
    @State var list = [Memo]()
    @State var mode: CurrentMode = .viewer
    
    private let insertSql = "INSERT INTO MEMO_TABLE(memo) VALUES(?);"
    private let deleteSql = "DELETE FROM MEMO_TABLE WHERE id = ?;"
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
                .frame(height: 10)
            createModeButtonArea()
            createModeActionArea {
                Task { [memo] in
                    switch mode {
                    case .viewer:
                        await insertMemo(memo)
                    case .search:
                        list = await searchMemo(memo)
                    }
                }
            }
                .padding(.bottom, 16)
            createMemoListArea()
        }
        .task {
            
            list = await fetchCurrentList()
        }
    }
    
    func createModeButtonArea() -> some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: .zero) {
                HStack(spacing: .zero) {
                    ForEach(CurrentMode.allCases, id: \.hashValue) { mode in
                        VStack(spacing: .zero) {
                            Button {
                                withAnimation {
                                    self.mode = mode
                                    Task {
                                        list = await fetchCurrentList()
                                    }
                                }
                            } label: {
                                Text(mode.rawValue)
                                    .frame(height: 60)
                                    .frame(maxWidth: proxy.size.width)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .defaultButtonStyle(foregroundColor: self.mode == mode ? .white : .black,
                                                backgroundColor: self.mode == mode ? .black : .white,
                                                borderWidth: 1)
                        }
                    }
                }
                Rectangle()
                    .frame(width: proxy.size.width / 2, height: 10)
                    .offset(x: mode == .viewer ? .zero : proxy.size.width / 2)
                    .foregroundStyle(.gray)
            }
        }
        .frame(height: 70)
    }
    
    func createMemoListArea() -> some View {
        VStack(spacing: .zero) {
            Text("Memo List")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            Spacer()
                .frame(height: 8)
            List {
                ForEach(list, id: \.id) { item in
                    HStack {
                        Text(item.memo)
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .onDelete { indexSet in
                    Task {
                        guard indexSet.indices.contains(indexSet.startIndex),
                              await deleteMemo(id: list[indexSet[indexSet.startIndex]].id) else { return }
                        list.remove(atOffsets: indexSet)
                    }
                }
            }
            .listStyle(.plain)
            .padding()
        }
    }
    
    func createModeActionArea(action: @escaping () -> Void) -> some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Spacer()
                .frame(height: 16)
            TextField(text: $memo) {
                Text("memo")
            }
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1)
            }
            Spacer()
                .frame(height: 8)
            Button {
                action()
                memo = ""
            } label: {
                Text(mode.executeButtonTitle)
                    .frame(height: 45)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 16, weight: .bold))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
    }
    
    func fetchCurrentList() async -> [Memo] {
        do {
            return try await DataBase.shared.select(Memo.createAllSeletByIdQuery())
        }
        catch {
            print("occured fetch list items(\(error))")
            return []
        }
    }
    
    func searchMemo(_ key: String) async -> [Memo] {
        do {
            print("searchMemo key: \(key)")
            return try await DataBase.shared.select(Memo.createSelectByMemoQuery(key))
        }
        catch {
            print("occured fetch list items(\(error))")
            return []
        }
    }
    
    func insertMemo(_ key: String) async {
        do {
            print("insertMemo key: \(key)")
            try await DataBase.shared.insert(insertSql, binds: [.string(NSString(string: key))])
            let list = await fetchCurrentList()
            self.list = list
        }
        catch {
            print("occured error \(error)")
        }
    }
    
    func deleteMemo(id: Int) async -> Bool {
        do {
            try await DataBase.shared.delete(deleteSql, binds: [.int32(Int32(id))])
            return true
        }
        catch {
            print("occured error \(error)")
            return false
        }
    }
}

#Preview {
    ContentView()
}
