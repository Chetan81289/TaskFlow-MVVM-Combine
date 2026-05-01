//
//  Task.swift
//  TaskFlow
//
//  Created by Chetan Purohit on 01/05/26.
//

import Foundation

struct Task: Identifiable, Equatable {
    let id: UUID
    var title: String
    var details: String?
    var priority: Priority
    var status: TaskStatus
    let createdAt: Date
    var dueDate: Date?

    enum Priority: Int, CaseIterable {
        case low, normal, high
    }

    enum TaskStatus: String, CaseIterable {
        case todo = "To-Do"
        case inProgress = "In Progress"
        case done = "Done"
    }
}
