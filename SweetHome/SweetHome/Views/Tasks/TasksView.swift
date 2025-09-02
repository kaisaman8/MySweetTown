//
//  TasksView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI
import CoreData

struct TasksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataManager: CoreDataManager
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \Task.createdDate, ascending: false)
        ],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Streak.currentStreak, ascending: false)],
        animation: .default)
    private var streaks: FetchedResults<Streak>
    
    @State private var showingAddTask = false
    @State private var showingCompletionAnimation = false
    @State private var completedTaskId: UUID?
    @State private var showingMotivation = false
    
    var incompleteTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }
    
    var completedToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return tasks.filter { task in
            guard let completedDate = task.lastCompletedDate else { return false }
            return completedDate >= today && completedDate < tomorrow
        }.count
    }
    
    var currentStreak: Int {
        Int(streaks.first?.currentStreak ?? 0)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Header
                if !tasks.isEmpty {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("📋 Your Tasks")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Stay productive and earn sweet rewards!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingMotivation = true
                            }) {
                                Image(systemName: "star.circle")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Today's Progress
                        HStack(spacing: 16) {
                            ProgressCard(
                                icon: "checkmark.circle.fill",
                                value: "\(completedToday)",
                                label: "Completed Today",
                                color: .green
                            )
                            
                            ProgressCard(
                                icon: "list.bullet.circle",
                                value: "\(incompleteTasks.count)",
                                label: "Remaining",
                                color: .blue
                            )
                            
                            ProgressCard(
                                icon: "flame.fill",
                                value: "\(currentStreak)",
                                label: "Day Streak",
                                color: .orange
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
                
                List {
                    // Motivation section for empty state
                    if tasks.isEmpty {
                        VStack(spacing: 20) {
                            VStack(spacing: 16) {
                                Text("🎯")
                                    .font(.system(size: 60))
                                
                                Text("Ready to Get Sweet?")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Create your first task and start earning delicious rewards!")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            VStack(spacing: 12) {
                                MotivationRow(
                                    icon: "🍬",
                                    text: "Each completed task earns you sweet treats"
                                )
                                
                                MotivationRow(
                                    icon: "🔥",
                                    text: "Build streaks for bonus rewards"
                                )
                                
                                MotivationRow(
                                    icon: "🏆",
                                    text: "Collect rare and legendary sweets"
                                )
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            Button(action: {
                                showingAddTask = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create Your First Task")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    
                    // Active tasks section
                    if !incompleteTasks.isEmpty {
                        Section {
                            ForEach(incompleteTasks, id: \.id) { task in
                                TaskRowView(task: task, onComplete: { task in
                                    completeTask(task)
                                })
                            }
                            .onDelete(perform: deleteIncompleteTasks)
                        } header: {
                            HStack {
                                Text("🎯 Active Tasks")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("\(incompleteTasks.count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Completed tasks section
                    if !completedTasks.isEmpty {
                        Section {
                            ForEach(completedTasks, id: \.id) { task in
                                TaskRowView(task: task, onComplete: nil)
                                    .opacity(0.7)
                            }
                            .onDelete(perform: deleteCompletedTasks)
                        } header: {
                            HStack {
                                Text("✅ Completed")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text("\(completedTasks.count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
            .sheet(isPresented: $showingMotivation) {
                MotivationView()
            }
            .overlay(
                // Completion animation overlay
                Group {
                    if showingCompletionAnimation {
                        CompletionAnimationView()
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            )
        }
    }
    
    private func completeTask(_ task: Task) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            coreDataManager.completeTask(task)
            completedTaskId = task.id
            showingCompletionAnimation = true
        }
        
        // Hide animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingCompletionAnimation = false
                completedTaskId = nil
            }
        }
    }
    
    private func deleteIncompleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { incompleteTasks[$0] }.forEach(coreDataManager.deleteTask)
        }
    }
    
    private func deleteCompletedTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { completedTasks[$0] }.forEach(coreDataManager.deleteTask)
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let onComplete: ((Task) -> Void)?
    
    @State private var showingEditTask = false
    
    private var priority: TaskPriority {
        TaskPriority(rawValue: task.priority ?? "medium") ?? .medium
    }
    
    private var category: TaskCategory? {
        guard let categoryString = task.category else { return nil }
        return TaskCategory(rawValue: categoryString)
    }
    
    private var recurrence: RecurrenceType {
        RecurrenceType(rawValue: task.recurrenceType ?? "none") ?? .none
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: {
                if let onComplete = onComplete {
                    onComplete(task)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid interfering with the row's tap gesture
            .disabled(task.isCompleted)
            .contentShape(Rectangle()) // Ensure the button's tap area is recognized
            
            VStack(alignment: .leading, spacing: 4) {
                // Title and priority
                HStack {
                    Text(task.title ?? "Untitled Task")
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    // Priority indicator
                    Image(systemName: priority.iconName)
                        .foregroundColor(Color(priority.color))
                        .font(.caption)
                }
                
                // Description
                if let description = task.taskDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Category and recurrence
                HStack(spacing: 12) {
                    if let category = category {
                        Label(category.displayName, systemImage: category.iconName)
                            .font(.caption)
                            .foregroundColor(Color(category.color))
                    }
                    
                    if recurrence != .none {
                        Label(recurrence.displayName, systemImage: recurrence.iconName)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !task.isCompleted {
                showingEditTask = true
            }
        }
        .sheet(isPresented: $showingEditTask) {
            EditTaskView(task: task)
        }
    }
}

struct CompletionAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var sweetScale: CGFloat = 0.5
    @State private var confettiOpacity: Double = 0
    @State private var sparkleRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: 20) {
                // Animated checkmark with sparkles
                ZStack {
                    // Sparkle effects
                    ForEach(0..<8, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .font(.title3)
                            .foregroundColor(.yellow)
                            .offset(
                                x: cos(Double(index) * .pi / 4) * 60,
                                y: sin(Double(index) * .pi / 4) * 60
                            )
                            .rotationEffect(.degrees(sparkleRotation))
                            .opacity(confettiOpacity)
                    }
                    
                    // Main checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                        .scaleEffect(checkmarkScale)
                        .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                VStack(spacing: 12) {
                    Text("🎉 Task Completed!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 8) {
                        Text("🍬")
                            .font(.title)
                            .scaleEffect(sweetScale)
                        
                        Text("Sweet Reward Earned!")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    Text("Keep up the great work!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Staggered animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                checkmarkScale = 1.0
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                sweetScale = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                confettiOpacity = 1.0
            }
            
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false).delay(0.2)) {
                sparkleRotation = 360
            }
        }
    }
}

// MARK: - Supporting Views

struct ProgressCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct MotivationRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title3)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct MotivationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Text("🎯")
                            .font(.system(size: 60))
                        
                        Text("Stay Motivated!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Every task you complete brings you closer to sweet success!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    VStack(spacing: 20) {
                        MotivationCard(
                            icon: "🍬",
                            title: "Sweet Rewards",
                            description: "Each completed task earns you delicious sweets for your collection. The more you complete, the sweeter it gets!"
                        )
                        
                        MotivationCard(
                            icon: "🔥",
                            title: "Build Streaks",
                            description: "Complete tasks on consecutive days to build powerful streaks. Longer streaks unlock special bonus rewards!"
                        )
                        
                        MotivationCard(
                            icon: "🏆",
                            title: "Rare Collections",
                            description: "Discover rare and legendary sweets! Some treats are so special, they only appear for the most dedicated achievers."
                        )
                        
                        MotivationCard(
                            icon: "📈",
                            title: "Track Progress",
                            description: "Watch your productivity soar as you build habits, complete goals, and create your sweet success story."
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Text("💡 Pro Tips")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            TipRow(tip: "Start small - even tiny tasks count!")
                            TipRow(tip: "Set priorities to focus on what matters most")
                            TipRow(tip: "Use categories to organize your life")
                            TipRow(tip: "Daily completion keeps your streak alive")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Motivation")
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

struct MotivationCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct TipRow: View {
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
    TasksView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environmentObject(CoreDataManager.shared)
}
