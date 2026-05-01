//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Chetan Purohit on 01/05/26.
//

import SwiftUI
import CoreData

@main
struct TaskFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TaskListView()
            .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
