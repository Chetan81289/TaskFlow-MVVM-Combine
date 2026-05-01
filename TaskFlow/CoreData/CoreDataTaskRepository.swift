//
//  CoreDataTaskRepository.swift
//  TaskFlow
//
//  Created by Chetan Purohit on 01/05/26.
//

import Combine
import CoreData
import Foundation

final class CoreDataTaskRepository: TaskRepositoryProtocol {
    private let persistence: PersistenceController

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

    // MARK: - Fetch with change notifications

    func fetchTasks() -> AnyPublisher<[Task], Error> {
        let initialFetch = Just(())
            .tryMap { [weak self] _ -> [Task] in
                guard let self else { throw RepositoryError.deallocated }
                return try self.loadAllTasks()
            }

        let changeUpdate = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: nil)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .tryMap { [weak self] _ -> [Task] in
                guard let self else { throw RepositoryError.deallocated }
                return try self.loadAllTasks()
            }

        return initialFetch
            .append(changeUpdate)
            .eraseToAnyPublisher()
    }

    private func loadAllTasks() throws -> [Task] {
        let context = persistence.viewContext
        let request = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)]
        return try context.fetch(request).map { $0.domainModel }
    }

    // MARK: - Write Operations

    func addTask(_ task: Task) -> AnyPublisher<Void, Error> {
        performBackground(context: persistence.newBackgroundContext()) { context in
            let entity = TaskEntity(context: context)
            entity.update(from: task)
            try context.save()
        }
    }

    func updateTask(_ task: Task) -> AnyPublisher<Void, Error> {
        performBackground(context: persistence.newBackgroundContext()) { context in
            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            if let entity = try context.fetch(request).first {
                entity.update(from: task)
                try context.save()
            } else {
                throw RepositoryError.taskNotFound
            }
        }
    }

    func deleteTask(id: UUID) -> AnyPublisher<Void, Error> {
        performBackground(context: persistence.newBackgroundContext()) { context in
            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
            } else {
                throw RepositoryError.taskNotFound
            }
        }
    }

    private func performBackground(
        context: NSManagedObjectContext,
        operation: @escaping (NSManagedObjectContext) throws -> Void
    ) -> AnyPublisher<Void, Error> {
        Deferred {
            Future<Void, Error> { promise in
                context.perform {
                    do {
                        try operation(context)
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

enum RepositoryError: Error, LocalizedError {
    case taskNotFound
    case deallocated

    var errorDescription: String? {
        switch self {
        case .taskNotFound: return "Task not found"
        case .deallocated: return "Repository was deallocated unexpectedly"
        }
    }
}
