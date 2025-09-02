//
//  ExportImportService.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import Foundation
import CoreData

struct ExportData: Codable {
    let version: String
    let exportDate: Date
    let tasks: [ExportTask]
    let sweets: [ExportSweet]
    let settings: ExportSettings
    let streaks: [ExportStreak]
    let completionHistory: [ExportCompletion]
}

struct ExportTask: Codable {
    let id: UUID
    let title: String
    let taskDescription: String?
    let category: String?
    let priority: String
    let recurrenceType: String
    let isCompleted: Bool
    let createdDate: Date
    let lastCompletedDate: Date?
}

struct ExportSweet: Codable {
    let id: UUID
    let name: String
    let sweetType: String
    let rarity: String
    let iconName: String
    let earnedDate: Date
}

struct ExportSettings: Codable {
    let sweetsPerTask: Int16
    let theme: String
    let streakBonusEnabled: Bool
}

struct ExportStreak: Codable {
    let currentStreak: Int16
    let longestStreak: Int16
    let lastCompletionDate: Date?
}

struct ExportCompletion: Codable {
    let completedDate: Date
    let sweetsEarned: Int16
    let taskId: UUID
}

class ExportImportService {
    
    func exportData(context: NSManagedObjectContext) -> Data? {
        do {
            // Fetch all data
            let tasks = try context.fetch(Task.fetchRequest()) as [Task]
            let sweets = try context.fetch(Sweet.fetchRequest()) as [Sweet]
            let settings = try context.fetch(AppSettings.fetchRequest()) as [AppSettings]
            let streaks = try context.fetch(Streak.fetchRequest()) as [Streak]
            let completions = try context.fetch(CompletionHistory.fetchRequest()) as [CompletionHistory]
            
            // Convert to export format
            let exportTasks = tasks.map { task in
                ExportTask(
                    id: task.id ?? UUID(),
                    title: task.title ?? "",
                    taskDescription: task.taskDescription,
                    category: task.category,
                    priority: task.priority ?? "medium",
                    recurrenceType: task.recurrenceType ?? "none",
                    isCompleted: task.isCompleted,
                    createdDate: task.createdDate ?? Date(),
                    lastCompletedDate: task.lastCompletedDate
                )
            }
            
            let exportSweets = sweets.map { sweet in
                ExportSweet(
                    id: sweet.id ?? UUID(),
                    name: sweet.name ?? "",
                    sweetType: sweet.sweetType ?? "candy",
                    rarity: sweet.rarity ?? "common",
                    iconName: sweet.iconName ?? "🍬",
                    earnedDate: sweet.earnedDate ?? Date()
                )
            }
            
            let exportSettings = ExportSettings(
                sweetsPerTask: settings.first?.sweetsPerTask ?? 1,
                theme: settings.first?.theme ?? "system",
                streakBonusEnabled: settings.first?.streakBonusEnabled ?? true
            )
            
            let exportStreaks = streaks.map { streak in
                ExportStreak(
                    currentStreak: streak.currentStreak,
                    longestStreak: streak.longestStreak,
                    lastCompletionDate: streak.lastCompletionDate
                )
            }
            
            let exportCompletions = completions.compactMap { completion -> ExportCompletion? in
                guard let taskId = completion.task?.id else { return nil }
                return ExportCompletion(
                    completedDate: completion.completedDate ?? Date(),
                    sweetsEarned: completion.sweetsEarned,
                    taskId: taskId
                )
            }
            
            let exportData = ExportData(
                version: "1.0",
                exportDate: Date(),
                tasks: exportTasks,
                sweets: exportSweets,
                settings: exportSettings,
                streaks: exportStreaks,
                completionHistory: exportCompletions
            )
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            return try encoder.encode(exportData)
            
        } catch {
            print("Export error: \(error)")
            return nil
        }
    }
    
    func importData(_ data: Data, context: NSManagedObjectContext, coreDataManager: CoreDataManager) -> Bool {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let importData = try decoder.decode(ExportData.self, from: data)
            
            // Clear existing data
            coreDataManager.clearAllData()
            
            // Import settings
            let settings = coreDataManager.getAppSettings()
            settings.sweetsPerTask = importData.settings.sweetsPerTask
            settings.theme = importData.settings.theme
            settings.streakBonusEnabled = importData.settings.streakBonusEnabled
            settings.isFirstLaunch = false
            
            // Import tasks
            for taskData in importData.tasks {
                let task = Task(context: context)
                task.id = taskData.id
                task.title = taskData.title
                task.taskDescription = taskData.taskDescription
                task.category = taskData.category
                task.priority = taskData.priority
                task.recurrenceType = taskData.recurrenceType
                task.isCompleted = taskData.isCompleted
                task.createdDate = taskData.createdDate
                task.lastCompletedDate = taskData.lastCompletedDate
            }
            
            // Import sweets
            for sweetData in importData.sweets {
                let sweet = Sweet(context: context)
                sweet.id = sweetData.id
                sweet.name = sweetData.name
                sweet.sweetType = sweetData.sweetType
                sweet.rarity = sweetData.rarity
                sweet.iconName = sweetData.iconName
                sweet.earnedDate = sweetData.earnedDate
            }
            
            // Import streaks
            for streakData in importData.streaks {
                let streak = Streak(context: context)
                streak.currentStreak = streakData.currentStreak
                streak.longestStreak = streakData.longestStreak
                streak.lastCompletionDate = streakData.lastCompletionDate
            }
            
            // Import completion history
            let tasks = try context.fetch(Task.fetchRequest()) as [Task]
            let taskDict = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id!, $0) })
            
            for completionData in importData.completionHistory {
                if let task = taskDict[completionData.taskId] {
                    let completion = CompletionHistory(context: context)
                    completion.completedDate = completionData.completedDate
                    completion.sweetsEarned = completionData.sweetsEarned
                    completion.task = task
                }
            }
            
            coreDataManager.save()
            return true
            
        } catch {
            print("Import error: \(error)")
            return false
        }
    }
}
