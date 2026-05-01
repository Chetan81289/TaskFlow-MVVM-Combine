//
//  TaskListView.swift
//  TaskFlow
//
//  Created by Chetan Purohit on 01/05/26.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter picker
                Picker("Filter", selection: $viewModel.filterStatus) {
                    Text("All").tag(Task.TaskStatus?.none)
                    ForEach(Task.TaskStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(Task.TaskStatus?.some(status))
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // List
                if viewModel.filteredTasks.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    List {
                        ForEach(viewModel.filteredTasks) { task in
                            TaskRowView(task: task)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        if let index = viewModel.filteredTasks.firstIndex(where: { $0.id == task.id }) {
                                            viewModel.deleteTask(at: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .onTapGesture {
                                    // Cycle status on tap
                                    let nextStatus: Task.TaskStatus = {
                                        switch task.status {
                                        case .todo: return .inProgress
                                        case .inProgress: return .done
                                        case .done: return .todo
                                        }
                                    }()
                                    var updated = task
                                    updated.status = nextStatus
                                    viewModel.updateTask(updated)
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("TaskFlow")
            .searchable(text: $viewModel.searchText, prompt: "Search tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditTaskView { newTask in
                    viewModel.addTask(newTask)
                }
            }
            .overlay(alignment: .top) {
                // Error banner
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding()
                        .background(.red.opacity(0.9), in: Capsule())
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(), value: viewModel.errorMessage != nil)
                }
            }
        }
    }
}
