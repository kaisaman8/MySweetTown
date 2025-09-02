//
//  SettingsView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataManager: CoreDataManager
    @EnvironmentObject private var onboardingManager: OnboardingManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppSettings.sweetsPerTask, ascending: true)],
        animation: .default)
    private var appSettings: FetchedResults<AppSettings>
    
    @State private var sweetsPerTask: Double = 1
    @State private var selectedTheme = "system"
    @State private var streakBonusEnabled = true
    @State private var showingClearDataAlert = false
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var exportData: Data?
    
    private var settings: AppSettings {
        appSettings.first ?? coreDataManager.getAppSettings()
    }
    
    var body: some View {
        NavigationView {
            Form {
                // App Info Header
                Section {
                    VStack(spacing: 16) {
                        Text("🏠")
                            .font(.system(size: 50))
                        
                        VStack(spacing: 4) {
                            Text("Sweet Home")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Your productivity paradise")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .listRowBackground(Color(.systemGray6))
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🍬 Sweets per Task")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(Int(sweetsPerTask))")
                                .foregroundColor(.orange)
                                .fontWeight(.semibold)
                        }
                        
                        Text("How many sweets you earn for each completed task")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $sweetsPerTask, in: 1...5, step: 1)
                            .accentColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("🔥 Streak Bonus", isOn: $streakBonusEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                        
                        Text("Earn extra sweets for maintaining daily completion streaks")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("🎮 Gamification")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Theme", selection: $selectedTheme) {
                            Label("System", systemImage: "gear")
                                .tag("system")
                            Label("Light", systemImage: "sun.max")
                                .tag("light")
                            Label("Dark", systemImage: "moon")
                                .tag("dark")
                        }
                        .pickerStyle(.menu)
                        
                        Text("Choose your preferred app appearance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("🎨 Appearance")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Section {
                    Button(action: {
                        triggerExport()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                                .foregroundColor(.primary)
                            
                            Text("Save your tasks and sweets to a file")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showingImportSheet = true
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Import Data", systemImage: "square.and.arrow.down")
                                .foregroundColor(.primary)
                            
                            Text("Restore your data from a backup file")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        onboardingManager.resetOnboarding()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Show Onboarding", systemImage: "questionmark.circle")
                                .foregroundColor(.orange)
                            
                            Text("View the app introduction again")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showingClearDataAlert = true
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Clear All Data", systemImage: "trash")
                                .foregroundColor(.red)
                            
                            Text("Permanently delete all tasks and sweets")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("💾 Data Management")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Section {
                    StatisticsView()
                } header: {
                    Text("📊 Your Statistics")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Developer")
                            Spacer()
                            Text("Sweet Home Team")
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("🍬 About Sweet Home")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Transform your daily tasks into a delightful adventure! Complete tasks, earn sweet rewards, and build productive habits in your very own Sweet Home.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)
                    }
                } header: {
                    Text("ℹ️ About")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadSettings()
            }
            .onChange(of: sweetsPerTask) { _, newValue in
                saveSettings()
            }
            .onChange(of: selectedTheme) { _, newValue in
                saveSettings()
            }
            .onChange(of: streakBonusEnabled) { _, newValue in
                saveSettings()
            }
            .alert("Clear All Data", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your tasks, sweets, and progress. This action cannot be undone.")
            }
            .sheet(isPresented: $showingExportSheet) {
                if let exportData = exportData {
                    ExportDataView(data: exportData)
                }
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportDataView()
            }
        }
    }
    
    private func loadSettings() {
        let currentSettings = settings
        sweetsPerTask = Double(currentSettings.sweetsPerTask)
        selectedTheme = currentSettings.theme ?? "system"
        streakBonusEnabled = currentSettings.streakBonusEnabled
    }
    
    private func saveSettings() {
        coreDataManager.updateSettings(
            sweetsPerTask: Int16(sweetsPerTask),
            theme: selectedTheme,
            streakBonusEnabled: streakBonusEnabled
        )
    }
    
    private func clearAllData() {
        coreDataManager.clearAllData()
        // Reset to default settings
        sweetsPerTask = 1
        selectedTheme = "system"
        streakBonusEnabled = true
    }
    
    private func triggerExport() {
        let exportService = ExportImportService()
        exportData = exportService.exportData(context: viewContext)
        showingExportSheet = true
    }
}

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdDate, ascending: false)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Sweet.earnedDate, ascending: false)],
        animation: .default)
    private var sweets: FetchedResults<Sweet>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CompletionHistory.completedDate, ascending: false)],
        animation: .default)
    private var completions: FetchedResults<CompletionHistory>
    
    var completedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var totalTasks: Int {
        tasks.count
    }
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks) * 100
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Tasks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalTasks)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(completedTasks)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Completion Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(completionRate))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Total Sweets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(sweets.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
        .environmentObject(CoreDataManager.shared)
        .environmentObject(OnboardingManager.shared)
}
