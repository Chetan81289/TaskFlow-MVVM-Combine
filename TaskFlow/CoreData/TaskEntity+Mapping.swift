//
//  TaskEntity+Mapping.swift
//  TaskFlow
//
//  Created by Chetan Purohit on 01/05/26.
//

extension TaskEntity {
    /// Converts a Core Data entity to the domain model.
    var domainModel: Task {
        Task(
            id: self.id,
            title: self.title,
            details: self.details,
            priority: Task.Priority(rawValue: Int(self.priority)) ?? .normal,
            status: Task.TaskStatus(rawValue: self.status) ?? .todo,
            createdAt: self.createdAt,
            dueDate: self.dueDate
        )
    }

    /// Updates the entity with values from a domain model.
    func update(from task: Task) {
        self.id = task.id
        self.title = task.title
        self.details = task.details
        self.priority = Int16(task.priority.rawValue)
        self.status = task.status.rawValue
        self.dueDate = task.dueDate
        self.createdAt = task.createdAt
    }
}
