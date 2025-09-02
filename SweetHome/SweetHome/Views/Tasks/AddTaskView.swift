//
//  AddTaskView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coreDataManager: CoreDataManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: TaskCategory? = nil
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedRecurrence: RecurrenceType = .none
    @State private var showingHelp = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with motivation
                    VStack(spacing: 12) {
                        Text("🎯")
                            .font(.system(size: 50))
                        
                        Text("Create a New Task")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Every task you complete earns you sweet rewards!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        // Task Details Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("📝 Task Details")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Title *")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    TextField("What do you want to accomplish?", text: $title)
                                        .textFieldStyle(.roundedBorder)
                                        .submitLabel(.next)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    TextField("Add more details (optional)", text: $description, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .lineLimit(3...6)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        
                        // Category Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("🏷️ Category")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                
                                Button(action: {
                                    showingHelp = true
                                }) {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Choose a category to organize your tasks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Category", selection: $selectedCategory) {
                                    Text("No Category").tag(nil as TaskCategory?)
                                    ForEach(TaskCategory.allCases, id: \.self) { category in
                                        Label(category.displayName, systemImage: category.iconName)
                                            .tag(category as TaskCategory?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        
                        // Priority Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("⚡ Priority")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Set the importance level of this task")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Priority", selection: $selectedPriority) {
                                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                                        Label(priority.displayName, systemImage: priority.iconName)
                                            .tag(priority)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        
                        // Recurrence Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("🔄 Repeat")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Make this a recurring task to build habits")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Repeat", selection: $selectedRecurrence) {
                                    ForEach(RecurrenceType.allCases, id: \.self) { recurrence in
                                        Label(recurrence.displayName, systemImage: recurrence.iconName)
                                            .tag(recurrence)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        
                        // Sweet Reward Preview
                        VStack(spacing: 12) {
                            HStack {
                                Text("🍬 Sweet Reward")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                Text("🎁")
                                    .font(.title)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Complete this task to earn a sweet!")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("You might get anything from a common candy to a legendary treat!")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Save Button
                        Button(action: saveTask) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Task")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.orange)
                            )
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingHelp) {
                TaskHelpView()
            }
        }
    }
    
    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        _ = coreDataManager.createTask(
            title: trimmedTitle,
            description: trimmedDescription.isEmpty ? "" : trimmedDescription,
            category: selectedCategory?.rawValue,
            priority: selectedPriority.rawValue,
            recurrenceType: selectedRecurrence.rawValue
        )
        
        dismiss()
    }
}

struct TaskHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Text("💡")
                            .font(.system(size: 60))
                        
                        Text("Task Creation Guide")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Learn how to create effective tasks that help you stay productive!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    VStack(spacing: 20) {
                        HelpCard(
                            icon: "🏷️",
                            title: "Categories",
                            description: "Organize your tasks by life areas:",
                            items: [
                                "💼 Work - Professional tasks and projects",
                                "🏠 Personal - Home and family activities",
                                "💪 Health - Exercise, diet, and wellness",
                                "🎓 Learning - Education and skill development",
                                "💰 Finance - Money management and planning",
                                "🎨 Creative - Art, hobbies, and creative projects"
                            ]
                        )
                        
                        HelpCard(
                            icon: "⚡",
                            title: "Priorities",
                            description: "Set the right priority level:",
                            items: [
                                "🔴 High - Urgent and important tasks",
                                "🟡 Medium - Important but not urgent",
                                "🟢 Low - Nice to have, when time allows"
                            ]
                        )
                        
                        HelpCard(
                            icon: "🔄",
                            title: "Recurring Tasks",
                            description: "Build habits with repetition:",
                            items: [
                                "📅 Daily - For daily habits and routines",
                                "📆 Weekly - For weekly goals and reviews",
                                "🗓️ Monthly - For monthly planning and goals"
                            ]
                        )
                        
                        HelpCard(
                            icon: "🍬",
                            title: "Sweet Rewards",
                            description: "What you'll earn:",
                            items: [
                                "🍭 Common (50%) - Basic candies and treats",
                                "🧁 Uncommon (30%) - Cupcakes and cookies",
                                "🍰 Rare (15%) - Cakes and special desserts",
                                "🎂 Epic (4%) - Fancy pastries and delicacies",
                                "🏆 Legendary (1%) - Mythical sweet treasures"
                            ]
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Text("💡 Pro Tips")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            HelpTipRow(tip: "Start with small, achievable tasks")
                            HelpTipRow(tip: "Use clear, action-oriented titles")
                            HelpTipRow(tip: "Set realistic priorities")
                            HelpTipRow(tip: "Break large tasks into smaller ones")
                            HelpTipRow(tip: "Use recurring tasks for habits")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Task Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HelpCard: View {
    let icon: String
    let title: String
    let description: String
    let items: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(icon)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct HelpTipRow: View {
    let tip: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    AddTaskView()
        .environmentObject(CoreDataManager.shared)
}
