//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Jyoti Purohit on 01/05/26.
//

import SwiftUI
import CoreData

@main
struct TaskFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
