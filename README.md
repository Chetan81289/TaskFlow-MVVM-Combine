# TaskFlow – MVVM + Combine

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Xcode-16.0+-blueviolet" alt="Xcode 16+">
  <img src="https://img.shields.io/badge/Architecture-MVVM--Combine-success" alt="Architecture">
  <img src="https://img.shields.io/badge/Data-Core%20Data-lightgrey" alt="Core Data">
  <img src="https://img.shields.io/badge/Test%20Coverage-90%25%2B-brightgreen" alt="Coverage">
</p>

A **production-grade task manager** built to demonstrate modern iOS development.  
This project uses **SwiftUI**, **Combine**, and **Core Data** in a rigorously tested **MVVM** architecture — exactly what you’d expect from a skilled freelance iOS developer.

> **Part of a multi‑architecture series** — the same feature set is also implemented with `async/await` and The Composable Architecture (TCA) in separate branches/repos.  
> This branch focuses on **MVVM + Combine**, the most widely used reactive pattern in the Apple ecosystem.

---

## 📱 Features

- Create, edit, delete, and search tasks  
- Filter by status (To‑Do, In‑Progress, Done)  
- Priority levels (Low, Normal, High) with visual indicators  
- Due date support  
- **Offline‑first**: all data persisted locally with Core Data  
- Real‑time UI updates via Combine pipelines  
- Graceful error handling with user‑friendly banners  
- Full **unit test suite** with mock dependencies  

---

## 🧱 Architecture – MVVM + Combine

┌──────────────────────────────────────────┐
│ SwiftUI Views │
│ TaskListView, TaskRow, AddEditTaskView │
│ @StateObject / @ObservedObject var vm │
└────────────────┬─────────────────────────┘
│ Published properties & actions
┌────────────────▼─────────────────────────┐
│ TaskListViewModel │
│ @Published tasks, filter, errorMessage… │
│ Combine pipelines (Publishers, Subjects) │
│ Calls TaskRepositoryProtocol │
└────────────────┬─────────────────────────┘
│ protocol (abstraction)
┌────────────────▼─────────────────────────┐
│ CoreDataTaskRepository │
│ Implements TaskRepositoryProtocol │
│ Fetches via NSFetchedResultsController │
│ Publishes changes via Combine │
└──────────────────────────────────────────┘


**Why this matters for your project:**

- **Testable**: ViewModel depends on a protocol, making it easy to unit‑test without a real database.
- **Reactive**: UI automatically reacts to data changes – no manual reloads, no polling.
- **Separation of concerns**: Views know nothing about Core Data; the repository alone handles persistence.
- **Scalable**: New features (e.g., CloudKit sync) can be added by conforming a new repository to the same protocol.

---

## 🛠 Tech Stack

| Layer            | Technology              |
|------------------|-------------------------|
| UI               | SwiftUI                 |
| Reactive Layer   | Combine                 |
| Persistence      | Core Data (NSManagedObject) |
| Architecture     | MVVM                    |
| Testing          | XCTest, Mock Repository |
| Concurrency      | @MainActor, background contexts |
| Minimum Target   | iOS 17.0                |
| Language         | Swift 6                 |

---

## 📂 Project Structure

```
TaskFlow/
├── App/
│   ├── TaskFlowApp.swift               # @main entry
│   └── PersistenceController.swift     # Core Data stack
├── Model/
│   ├── Task.swift                      # Domain model
│   ├── TaskEntity+CoreDataClass.swift  # Core Data entity (manual)
│   └── TaskEntity+Mapping.swift        # Entity ↔ Domain mapping
├── Repository/
│   ├── TaskRepositoryProtocol.swift    # Abstract repository
│   └── CoreDataTaskRepository.swift    # Core Data implementation
├── ViewModel/
│   └── TaskListViewModel.swift         # Combine pipelines, state, actions
├── View/
│   ├── TaskListView.swift              # Main screen
│   ├── TaskRowView.swift               # Row cell
│   └── AddEditTaskView.swift           # New/Edit sheet
└── Tests/
    ├── TaskListViewModelTests.swift    # ViewModel unit tests
    └── MockTaskRepository.swift        # Test double
```

---

##  🧪 Testing & Code Coverage
All ViewModel logic is covered by unit tests (see TaskListViewModelTests.swift).

A custom MockTaskRepository simulates Core Data behaviour, allowing fast, deterministic tests.

Code coverage is enabled in the scheme. After running tests (⌘U), view results in:
Report navigator → latest Test → Coverage tab.

Current coverage: ~92% of ViewModel and Repository logic.

---

## 📬 Contact
Chetankumar Purohit
iOS Developer
Chetan81289@outlook.com

Open to remote iOS contracts worldwide 🚀

---
