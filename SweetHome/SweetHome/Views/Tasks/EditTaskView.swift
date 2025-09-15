//
//  EditTaskView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coreDataManager: CoreDataManager
    
    let task: Tasks
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: TaskCategory? = nil
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedRecurrence: RecurrenceType = .none
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Title", text: $title)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as TaskCategory?)
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.iconName)
                                .tag(category as TaskCategory?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Label(priority.displayName, systemImage: priority.iconName)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Recurrence") {
                    Picker("Repeat", selection: $selectedRecurrence) {
                        ForEach(RecurrenceType.allCases, id: \.self) { recurrence in
                            Label(recurrence.displayName, systemImage: recurrence.iconName)
                                .tag(recurrence)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    Button("Delete Task", role: .destructive) {
                        deleteTask()
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                loadTaskData()
            }
        }
    }
    
    private func loadTaskData() {
        title = task.title ?? ""
        description = task.taskDescription ?? ""
        
        if let categoryString = task.category {
            selectedCategory = TaskCategory(rawValue: categoryString)
        }
        
        if let priorityString = task.priority {
            selectedPriority = TaskPriority(rawValue: priorityString) ?? .medium
        }
        
        if let recurrenceString = task.recurrenceType {
            selectedRecurrence = RecurrenceType(rawValue: recurrenceString) ?? .none
        }
    }
    
    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        task.title = trimmedTitle
        task.taskDescription = trimmedDescription.isEmpty ? "" : trimmedDescription
        task.category = selectedCategory?.rawValue
        task.priority = selectedPriority.rawValue
        task.recurrenceType = selectedRecurrence.rawValue
        
        coreDataManager.save()
        dismiss()
    }
    
    private func deleteTask() {
        coreDataManager.deleteTask(task)
        dismiss()
    }
}

#Preview {
    let context = CoreDataManager.shared.context
    let sampleTask = Tasks(context: context)
    sampleTask.title = "Sample Task"
    sampleTask.taskDescription = "This is a sample task"
    sampleTask.priority = "medium"
    sampleTask.category = "work"
    sampleTask.recurrenceType = "daily"
    
    return EditTaskView(task: sampleTask)
        .environmentObject(CoreDataManager.shared)
}
