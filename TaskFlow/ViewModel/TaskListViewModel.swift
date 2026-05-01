//
//  TaskListViewModel.swift
//  TaskFlow
//
//  Created by Chetan Purohit on 01/05/26.
//

import Combine
import Foundation

@MainActor
final class TaskListViewModel: ObservableObject {

    // MARK: - Published Outputs

    @Published private(set) var tasks: [Task] = []
    @Published private(set) var filteredTasks: [Task] = []
    @Published var filterStatus: Task.TaskStatus? = nil
    @Published var searchText: String = ""
    @Published var errorMessage: String?

    // MARK: - Private

    private let repository: TaskRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialisation

    init(repository: TaskRepositoryProtocol = CoreDataTaskRepository()) {
        self.repository = repository
        setupBindings()
    }

    // MARK: - Bindings

    private func setupBindings() {
        // 1. Observe tasks from repository
        repository.fetchTasks()
            .catch { [weak self] error -> Just<[Task]> in
                self?.errorMessage = error.localizedDescription
                return Just([])
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.tasks, on: self)
            .store(in: &cancellables)

        // 2. Combine tasks, filter, and search into filteredTasks
        Publishers.CombineLatest3($tasks, $filterStatus, $searchText)
            .map { tasks, filter, search in
                tasks
                    .filter { task in
                        (filter == nil || task.status == filter) &&
                        (search.isEmpty || task.title.localizedCaseInsensitiveContains(search))
                    }
                    .sorted { $0.createdAt > $1.createdAt }
            }
            .assign(to: \.filteredTasks, on: self)
            .store(in: &cancellables)

        // 3. Auto-clear error after 3 seconds
        $errorMessage
            .compactMap { $0 }
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.errorMessage = nil }
            .store(in: &cancellables)
    }

    // MARK: - Public Actions

    func addTask(_ task: Task) {
        repository.addTask(task)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func updateTask(_ task: Task) {
        repository.updateTask(task)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func deleteTask(at offsets: IndexSet) {
        offsets.compactMap { index in
            filteredTasks[safe: index]?.id
        }.forEach { id in
            repository.deleteTask(id: id)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }
}

// Convenient safe array lookup
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
