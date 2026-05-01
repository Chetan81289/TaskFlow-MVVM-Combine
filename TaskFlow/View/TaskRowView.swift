//
//  TaskRowView.swift
//  TaskFlow
//
//  Created by Chetan Purohit on 01/05/26.
//

import SwiftUI

struct TaskRowView: View {
    let task: Task

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.status == .done, color: .secondary)

                if let details = task.details, !details.isEmpty {
                    Text(details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Priority indicator
            Circle()
                .fill(priorityColor)
                .frame(width: 12, height: 12)

            // Status badge
            Text(task.status.rawValue)
                .font(.caption2)
                .padding(6)
                .background(statusColor.opacity(0.2), in: Capsule())
                .foregroundColor(statusColor)
        }
        .padding(.vertical, 4)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .low: return .green
        case .normal: return .orange
        case .high: return .red
        }
    }

    private var statusColor: Color {
        switch task.status {
        case .todo: return .blue
        case .inProgress: return .purple
        case .done: return .gray
        }
    }
}
