//
//  TaskRepositoryProtocol.swift
//  TaskFlow
//
//  Created by Chetan Purohit on 01/05/26.
//

import Combine
import Foundation

protocol TaskRepositoryProtocol {
    func fetchTasks() -> AnyPublisher<[Task], Error>
    func addTask(_ task: Task) -> AnyPublisher<Void, Error>
    func updateTask(_ task: Task) -> AnyPublisher<Void, Error>
    func deleteTask(id: UUID) -> AnyPublisher<Void, Error>
}
