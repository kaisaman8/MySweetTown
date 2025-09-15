//
//  ContentView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject private var coreDataManager: CoreDataManager
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tasks.createdDate, ascending: false)],
        animation: .default)
    private var tasks: FetchedResults<Tasks>
    
    var body: some View {
        Group {
            if !hasSeenWelcome && tasks.isEmpty {
                WelcomeView(hasSeenWelcome: $hasSeenWelcome)
            } else {
                MainTabView()
            }
        }
    }
}

struct WelcomeView: View {
    @Binding var hasSeenWelcome: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Welcome
            VStack(spacing: 30) {
                Spacer()
                
                Text("🏠")
                    .font(.system(size: 100))
                
                VStack(spacing: 16) {
                    Text("Welcome to Sweet Home!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Transform your daily tasks into a delightful adventure")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button("Get Started") {
                    withAnimation {
                        currentPage = 1
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
                .padding(.bottom, 50)
            }
            .tag(0)
            
            // Page 2: How it works
            VStack(spacing: 30) {
                Spacer()
                
                Text("🎯")
                    .font(.system(size: 80))
                
                VStack(spacing: 20) {
                    Text("How It Works")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 16) {
                        FeatureRow(
                            icon: "📝",
                            title: "Create Tasks",
                            description: "Add your daily tasks and goals"
                        )
                        
                        FeatureRow(
                            icon: "✅",
                            title: "Complete & Earn",
                            description: "Finish tasks to earn sweet rewards"
                        )
                        
                        FeatureRow(
                            icon: "🍬",
                            title: "Collect Sweets",
                            description: "Build your delicious collection"
                        )
                        
                        FeatureRow(
                            icon: "🔥",
                            title: "Build Streaks",
                            description: "Stay consistent for bonus rewards"
                        )
                    }
                }
                
                Spacer()
                
                Button("Continue") {
                    withAnimation {
                        currentPage = 2
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
                .padding(.bottom, 50)
            }
            .tag(1)
            
            // Page 3: Sweet rewards
            VStack(spacing: 30) {
                Spacer()
                
                Text("🍭")
                    .font(.system(size: 80))
                
                VStack(spacing: 20) {
                    Text("Sweet Rewards")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Earn different rarities of sweets:")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        WelcomeRarityRow(emoji: "🍭", name: "Common", chance: "50%", color: .gray)
                        WelcomeRarityRow(emoji: "🧁", name: "Uncommon", chance: "30%", color: .green)
                        WelcomeRarityRow(emoji: "🍰", name: "Rare", chance: "15%", color: .blue)
                        WelcomeRarityRow(emoji: "🎂", name: "Epic", chance: "4%", color: .purple)
                        WelcomeRarityRow(emoji: "🏆", name: "Legendary", chance: "1%", color: .orange)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                Button("Start Your Journey!") {
                    withAnimation {
                        hasSeenWelcome = true
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(12)
                .padding(.bottom, 50)
            }
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.title)
                .frame(width: 50)
            
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
        .padding(.horizontal)
    }
}

struct WelcomeRarityRow: View {
    let emoji: String
    let name: String
    let chance: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(emoji)
                .font(.title2)
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            Spacer()
            
            Text(chance)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environmentObject(CoreDataManager.shared)
}
