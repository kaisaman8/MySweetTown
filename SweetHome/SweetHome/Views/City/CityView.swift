//
//  CityView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI
import CoreData

struct CityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataManager: CoreDataManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Sweet.earnedDate, ascending: false)],
        animation: .default)
    private var sweets: FetchedResults<Sweet>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Streak.currentStreak, ascending: false)],
        animation: .default)
    private var streaks: FetchedResults<Streak>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.isCompleted, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @State private var showingNewSweetAnimation = false
    @State private var showingHowItWorks = false
    @State private var newSweetOffset: CGFloat = -100
    
    private let columns = [
        GridItem(.adaptive(minimum: 90), spacing: 16)
    ]
    
    var currentStreak: Int {
        Int(streaks.first?.currentStreak ?? 0)
    }
    
    var longestStreak: Int {
        Int(streaks.first?.longestStreak ?? 0)
    }
    
    var activeTasks: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    var completedToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return tasks.filter { task in
            guard let completedDate = task.lastCompletedDate else { return false }
            return completedDate >= today && completedDate < tomorrow
        }.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🏠 Sweet Home")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                
                                Text("Your personal productivity paradise")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingHowItWorks = true
                            }) {
                                Image(systemName: "questionmark.circle")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Quick Stats Card
                        VStack(spacing: 16) {
                            HStack {
                                Text("📊 Today's Progress")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            HStack(spacing: 20) {
                                StatCard(
                                    icon: "checkmark.circle.fill",
                                    value: "\(completedToday)",
                                    label: "Completed Today",
                                    color: .green
                                )
                                
                                StatCard(
                                    icon: "list.bullet.circle",
                                    value: "\(activeTasks)",
                                    label: "Active Tasks",
                                    color: .blue
                                )
                                
                                StatCard(
                                    icon: "flame.fill",
                                    value: "\(currentStreak)",
                                    label: "Day Streak",
                                    color: .orange
                                )
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Achievement Stats
                    VStack(spacing: 16) {
                        HStack {
                            Text("🏆 Your Achievements")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            AchievementCard(
                                icon: "🔥",
                                title: "Best Streak",
                                value: "\(longestStreak) days",
                                subtitle: "Your longest streak",
                                color: .red
                            )
                            
                            AchievementCard(
                                icon: "🍬",
                                title: "Sweet Collection",
                                value: "\(sweets.count)",
                                subtitle: "Total sweets earned",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Sweet Collection Section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🍭 Sweet Collection")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Rewards earned from completing tasks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if sweets.isEmpty {
                            EmptyStateView()
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(sweets.prefix(12), id: \.id) { sweet in
                                    SweetCardView(sweet: sweet)
                                        .transition(.scale.combined(with: .opacity))
                                }
                                
                                if sweets.count > 12 {
                                    NavigationLink(destination: ShowcaseView()) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.orange.opacity(0.2))
                                                    .frame(width: 60, height: 60)
                                                
                                                Image(systemName: "plus")
                                                    .font(.title2)
                                                    .foregroundColor(.orange)
                                            }
                                            
                                            Text("View All")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.orange)
                                            
                                            Text("+\(sweets.count - 12) more")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingHowItWorks) {
                HowItWorksView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showingNewSweetAnimation = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingNewSweetAnimation = false
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
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
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 40))
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text("🎯")
                    .font(.system(size: 60))
                
                Text("Start Your Sweet Journey!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Complete tasks to earn delicious sweets")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Text("1️⃣")
                        .font(.title3)
                    Text("Create tasks in the Tasks tab")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Text("2️⃣")
                        .font(.title3)
                    Text("Complete them to earn sweets")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    Text("3️⃣")
                        .font(.title3)
                    Text("Build streaks for bonus rewards")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            NavigationLink(destination: TasksView()) {
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

struct HowItWorksView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Text("🏠")
                            .font(.system(size: 60))
                        
                        Text("How Sweet Home Works")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Turn your daily tasks into a sweet adventure!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    VStack(spacing: 20) {
                        FeatureCard(
                            icon: "📝",
                            title: "Create Tasks",
                            description: "Add your daily tasks, set priorities, and organize them by categories like work, health, or personal goals."
                        )
                        
                        FeatureCard(
                            icon: "✅",
                            title: "Complete & Earn",
                            description: "When you complete a task, you'll earn sweet rewards! Each completion gives you delicious treats for your collection."
                        )
                        
                        FeatureCard(
                            icon: "🍬",
                            title: "Collect Sweets",
                            description: "Sweets come in different rarities - from common candies to legendary treats. The more you complete, the better your collection!"
                        )
                        
                        FeatureCard(
                            icon: "🔥",
                            title: "Build Streaks",
                            description: "Complete tasks on consecutive days to build streaks. Longer streaks unlock bonus rewards and achievements!"
                        )
                        
                        FeatureCard(
                            icon: "🏆",
                            title: "Track Progress",
                            description: "Monitor your achievements, view your sweet collection, and see how your productivity grows over time."
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Text("Sweet Rarities")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            RarityRow(color: .gray, name: "Common", chance: "50%")
                            RarityRow(color: .green, name: "Uncommon", chance: "30%")
                            RarityRow(color: .blue, name: "Rare", chance: "15%")
                            RarityRow(color: .purple, name: "Epic", chance: "4%")
                            RarityRow(color: .orange, name: "Legendary", chance: "1%")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("How It Works")
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

struct FeatureCard: View {
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

struct RarityRow: View {
    let color: Color
    let name: String
    let chance: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(chance)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct SweetCardView: View {
    let sweet: Sweet
    @State private var isAnimating = false
    
    private var rarity: SweetRarity {
        SweetRarity(rawValue: sweet.rarity ?? "common") ?? .common
    }
    
    private var rarityColor: Color {
        switch rarity {
        case .common:
            return .gray
        case .uncommon:
            return .green
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return .orange
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(rarityColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text(sweet.iconName ?? "🍬")
                    .font(.system(size: 30))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            Text(sweet.name ?? "Sweet")
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(rarity.displayName)
                .font(.caption2)
                .foregroundColor(rarityColor)
                .fontWeight(.semibold)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: rarityColor.opacity(0.3), radius: 4, x: 0, y: 2)
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    CityView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environmentObject(CoreDataManager.shared)
}
