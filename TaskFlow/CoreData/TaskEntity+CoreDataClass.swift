//
//  TaskEntity+CoreDataClass.swift
//  TaskFlow
//
//  Created by Chetan Purohit on 01/05/26.
//

import CoreData

@objc(TaskEntity)
public class TaskEntity: NSManagedObject {}

extension TaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var details: String?
    @NSManaged public var priority: Int16
    @NSManaged public var status: String
    @NSManaged public var createdAt: Date
    @NSManaged public var dueDate: Date?
}
