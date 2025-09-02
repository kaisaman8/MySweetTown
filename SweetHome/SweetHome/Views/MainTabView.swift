//
//  MainTabView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI
import CoreData

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var coreDataManager: CoreDataManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.isCompleted, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Sweet.earnedDate, ascending: false)],
        animation: .default)
    private var sweets: FetchedResults<Sweet>
    
    var activeTasks: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CityView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Town")
                }
                .tag(0)
            
            TasksView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "list.bullet.circle.fill" : "list.bullet.circle")
                    Text("Tasks")
                }
                .badge(activeTasks > 0 ? activeTasks : 0)
                .tag(1)
            
            ShowcaseView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "star.circle.fill" : "star.circle")
                    Text("Collection")
                }
                .badge(sweets.count > 0 ? sweets.count : 0)
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "gear.circle.fill" : "gear.circle")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.orange)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Selected item appearance
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemOrange
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.systemOrange,
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
            ]
            
            // Normal item appearance
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 10, weight: .medium)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environmentObject(CoreDataManager.shared)
}
