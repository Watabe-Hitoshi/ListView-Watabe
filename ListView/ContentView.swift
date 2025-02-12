//
//  ContentView.swift
//  ListView
//
//  Created by hitoshi on 2025/02/09.
//

//
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        FirstView() // FirstViewを表示
        //SecondView()
    }
}

// リストの画面を新しい構造体に書き出す(ほぼコピー&ペースト)
struct FirstView: View {
    @AppStorage("TasksData") private var tasksData = Data()
    @State var tasksArray: [Task] = []
    
    // 画面生成時にtasksDataをデコードした値をtasksArrayに入れる
    init() {
        // tasksDataをデコードできたら、その値をtasksArrayに渡す
        if let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            _tasksArray = State(initialValue: decodedTasks)
            print(tasksArray)
        }
    }
    var body: some View {
        NavigationStack {
            // "Add New Task"の文字をタップするとSecondViewへ遷移するようにリンクを設定
            NavigationLink(destination: SecondView(tasksArray: $tasksArray).navigationTitle("Add Task")) {
                Text("Add New Task")
                    .font(.system(size: 20, weight: .bold))
                    .padding()
            }
            List {
                
                // ExampleTask の中の taskList を List の内側に ForEachを使って全て表示
                ForEach(tasksArray) {task in
                    Text(task.taskItem)
                }
                // リストの並べ替え時の処理を設定
                .onMove { from, to in
                    replaceRow(from, to)
                }
                .onDelete(perform: removeRow)
            }
            .navigationTitle("Task List") // 画面上のタイトル
            
            // ナビゲーションバーに編集ボタンを追加
            .toolbar {
                EditButton()
            }
        }
    }
    
    // 並び替え処理と並び替え後の保存
    func replaceRow(_ from: IndexSet, _ to: Int) {
        tasksArray.move(fromOffsets: from, toOffset: to) // 配列内での並び替え
        if let encodedArray = try? JSONEncoder().encode(tasksArray) {
            tasksData = encodedArray // エンコードできたらAppStorageに渡す(保存・更新)
        }
    }
    func removeRow(offsets: IndexSet) {
        tasksArray.remove(atOffsets: offsets)
        if let encodedArray = try? JSONEncoder().encode(tasksArray) {
            tasksData = encodedArray
        }
    }
}

struct SecondView: View {
    
    @Environment(\.dismiss) private var dismiss
    //テキストフィールドに入力された文字を格納する変数
    @State private var task: String = ""
    
    @Binding var tasksArray: [Task]
    
    var body: some View {
        TextField("Enter your task", text: $task)
            .textFieldStyle(.roundedBorder)
            .padding()
        
        Button{
            // ボタンを押したときの処理
            addTask(newTask: task) // 入力されたタスクの保存
            task = "" // テキストフィールドを初期化
            print(tasksArray) //
        } label: {
            Text("Add")
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .padding()
        
        Spacer()
    }
    
    // タスクの追加と保存 引数は入力されたタスクの文字
    func addTask(newTask: String) {
        // テキストフィールドに入力された値が空白じゃない(何か入力されている)ときだけ処理
        if !newTask.isEmpty {
            let task = Task(taskItem: newTask) // Taskをインスタンス化(実体化)
            var array = tasksArray
            array.append(task) // 一時的な配列ArrayにTaskを追加
            
            // エンコードがうまくいったらUserDefaultsに保存する
            if let encodedData = try? JSONEncoder().encode(array) {
                UserDefaults.standard.setValue(encodedData, forKey: "TasksData") // 保存
                tasksArray = array // 保存ができた時だけ 新しいTaskが追加された配列を反映
                dismiss()
            }
        }
    }
}
#Preview {
    ContentView()
}

//#Preview("Second View") {
//    SecondView()
//}
//コミットできない
