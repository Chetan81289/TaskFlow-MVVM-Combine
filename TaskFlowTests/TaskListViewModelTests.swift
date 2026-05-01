//
//  TaskListViewModelTests.swift
//  TaskFlowTests
//
//  Created by Chetan Purohit on 01/05/26.
//

import Combine
import XCTest
@testable import TaskFlow

final class TaskListViewModelTests: XCTestCase {

    var mockRepository: MockTaskRepository!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        cancellables = []
    }

    // MARK: - Tests

    @MainActor func test_initialState_tasksEmpty() {
        let vm = TaskListViewModel(repository: mockRepository)
        XCTAssertTrue(vm.tasks.isEmpty)
        XCTAssertTrue(vm.filteredTasks.isEmpty)
    }

    @MainActor func test_filtering_showsOnlyInProgress() {
        let tasks = [
            Task(id: UUID(), title: "A", priority: .normal, status: .todo, createdAt: Date()),
            Task(id: UUID(), title: "B", priority: .normal, status: .inProgress, createdAt: Date())
        ]
        mockRepository.tasksSubject.send(tasks)
        let vm = TaskListViewModel(repository: mockRepository)
        vm.filterStatus = .inProgress

        let expect = XCTestExpectation(description: "Filter applied")
        vm.$filteredTasks
            .dropFirst()
            .sink { filtered in
                XCTAssertEqual(filtered.count, 1)
                XCTAssertEqual(filtered.first?.status, .inProgress)
                expect.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expect], timeout: 1.0)
    }

    @MainActor func test_searchFiltersByTitle() {
        let tasks = [
            Task(id: UUID(), title: "Buy groceries", priority: .normal, status: .todo, createdAt: Date()),
            Task(id: UUID(), title: "Call dentist", priority: .normal, status: .todo, createdAt: Date())
        ]
        mockRepository.tasksSubject.send(tasks)
        let vm = TaskListViewModel(repository: mockRepository)
        vm.searchText = "dentist"

        let expect = XCTestExpectation(description: "Search applied")
        vm.$filteredTasks
            .dropFirst()
            .sink { filtered in
                XCTAssertEqual(filtered.count, 1)
                XCTAssertTrue(filtered.first?.title.contains("dentist") ?? false)
                expect.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expect], timeout: 1.0)
    }

    @MainActor func test_addTaskInvokesRepository() {
        let addExpectation = XCTestExpectation(description: "Add called")
        mockRepository.addResult = .success(())
        mockRepository.onAdd = { addExpectation.fulfill() }

        let vm = TaskListViewModel(repository: mockRepository)
        let newTask = Task(id: UUID(), title: "New", priority: .normal, status: .todo, createdAt: Date())
        vm.addTask(newTask)

        wait(for: [addExpectation], timeout: 1.0)
    }

    @MainActor
    func test_deleteTaskRemovesItem() {
        let task = Task(id: UUID(), title: "Temp", priority: .normal, status: .todo, createdAt: Date())
        mockRepository.tasksSubject.send([task])
        mockRepository.deleteResult = .success(())

        let vm = TaskListViewModel(repository: mockRepository)

        // 1. Wait for the initial data to appear in filteredTasks
        let dataLoaded = XCTestExpectation(description: "Data loaded")
        vm.$filteredTasks
            .dropFirst() // skip the initial (still empty) value if needed
            .sink { tasks in
                if !tasks.isEmpty {
                    dataLoaded.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [dataLoaded], timeout: 1.0)

        // 2. Now filteredTasks is not empty – set up the delete expectation
        let deleteExpectation = XCTestExpectation(description: "Delete called")
        mockRepository.onDelete = { id in
            XCTAssertEqual(id, task.id)
            deleteExpectation.fulfill()
        }

        // 3. Fire the delete
        vm.deleteTask(at: IndexSet(integer: 0))

        wait(for: [deleteExpectation], timeout: 1.0)
    }
    
    @MainActor
    func test_errorPropagationShowsErrorMessage() {
        mockRepository.fetchResult = .failure(RepositoryError.taskNotFound)
        let vm = TaskListViewModel(repository: mockRepository)
        XCTAssertNotNil(vm.errorMessage, "Error message should be set after fetch failure")
    }
}

// MARK: - Mock Repository

class MockTaskRepository: TaskRepositoryProtocol {
    var tasksSubject = CurrentValueSubject<[Task], Error>([])
    var fetchResult: Result<[Task], Error> = .success([])
    var addResult: Result<Void, Error> = .success(())
    var updateResult: Result<Void, Error> = .success(())
    var deleteResult: Result<Void, Error> = .success(())

    var onAdd: (() -> Void)?
    var onUpdate: ((Task) -> Void)?
    var onDelete: ((UUID) -> Void)?

    func fetchTasks() -> AnyPublisher<[Task], Error> {
        if case .failure(let error) = fetchResult {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return tasksSubject.eraseToAnyPublisher()
    }

    func addTask(_ task: Task) -> AnyPublisher<Void, Error> {
        onAdd?()
        return resultToPublisher(addResult)
    }

    func updateTask(_ task: Task) -> AnyPublisher<Void, Error> {
        onUpdate?(task)
        return resultToPublisher(updateResult)
    }

    func deleteTask(id: UUID) -> AnyPublisher<Void, Error> {
        onDelete?(id)
        return resultToPublisher(deleteResult)
    }

    private func resultToPublisher(_ result: Result<Void, Error>) -> AnyPublisher<Void, Error> {
        switch result {
        case .success:
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
