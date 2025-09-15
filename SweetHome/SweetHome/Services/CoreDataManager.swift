//
//  CoreDataManager.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import Foundation
import CoreData

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SweetHome")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    // MARK: - Task Operations
    
    func createTask(title: String, description: String, category: String?, priority: String, recurrenceType: String) -> Tasks {
        let task = Tasks(context: context)
        task.id = UUID()
        task.title = title
        task.taskDescription = description
        task.category = category
        task.priority = priority
        task.recurrenceType = recurrenceType
        task.isCompleted = false
        task.createdDate = Date()
        
        save()
        return task
    }
    
    func completeTask(_ task: Tasks) {
        task.isCompleted = true
        task.lastCompletedDate = Date()
        
        // Create completion history
        let completion = CompletionHistory(context: context)
        completion.completedDate = Date()
        completion.task = task
        
        // Award sweets
        let settings = getAppSettings()
        let sweetsToEarn = Int(settings.sweetsPerTask)
        completion.sweetsEarned = Int16(sweetsToEarn)
        
        // Create sweets
        for _ in 0..<sweetsToEarn {
            createRandomSweet()
        }
        
        // Update streak
        updateStreak()
        
        save()
    }
    
    func deleteTask(_ task: Tasks) {
        context.delete(task)
        save()
    }
    
    // MARK: - Sweet Operations
    
    func createRandomSweet() -> Sweet {
        let sweet = Sweet(context: context)
        sweet.id = UUID()
        sweet.earnedDate = Date()
        
        // Random sweet type
        let sweetTypes = SweetType.allCases
        let randomType = sweetTypes.randomElement()!
        sweet.sweetType = randomType.rawValue
        sweet.iconName = randomType.iconName
        sweet.name = randomType.displayName
        
        // Random rarity based on probability
        let randomValue = Double.random(in: 0...1)
        var cumulativeProbability = 0.0
        
        for rarity in SweetRarity.allCases.reversed() {
            cumulativeProbability += rarity.probability
            if randomValue <= cumulativeProbability {
                sweet.rarity = rarity.rawValue
                break
            }
        }
        
        save()
        return sweet
    }
    
    // MARK: - Streak Operations
    
    func updateStreak() {
        let streak = getOrCreateStreak()
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastCompletion = streak.lastCompletionDate {
            let lastCompletionDay = Calendar.current.startOfDay(for: lastCompletion)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastCompletionDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                streak.currentStreak += 1
            } else if daysDifference > 1 {
                // Streak broken
                streak.currentStreak = 1
            }
            // If daysDifference == 0, it's the same day, don't change streak
        } else {
            // First completion
            streak.currentStreak = 1
        }
        
        // Update longest streak
        if streak.currentStreak > streak.longestStreak {
            streak.longestStreak = streak.currentStreak
        }
        
        streak.lastCompletionDate = Date()
        save()
    }
    
    func getOrCreateStreak() -> Streak {
        let request: NSFetchRequest<Streak> = Streak.fetchRequest()
        
        do {
            let streaks = try context.fetch(request)
            if let existingStreak = streaks.first {
                return existingStreak
            }
        } catch {
            print("Error fetching streak: \(error)")
        }
        
        // Create new streak
        let streak = Streak(context: context)
        streak.currentStreak = 0
        streak.longestStreak = 0
        save()
        return streak
    }
    
    // MARK: - Settings Operations
    
    func getAppSettings() -> AppSettings {
        let request: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        
        do {
            let settings = try context.fetch(request)
            if let existingSettings = settings.first {
                return existingSettings
            }
        } catch {
            print("Error fetching settings: \(error)")
        }
        
        // Create default settings
        let settings = AppSettings(context: context)
        settings.sweetsPerTask = 1
        settings.theme = "system"
        settings.streakBonusEnabled = true
        settings.isFirstLaunch = true
        save()
        return settings
    }
    
    func updateSettings(sweetsPerTask: Int16, theme: String, streakBonusEnabled: Bool) {
        let settings = getAppSettings()
        settings.sweetsPerTask = sweetsPerTask
        settings.theme = theme
        settings.streakBonusEnabled = streakBonusEnabled
        save()
    }
    
    // MARK: - Demo Data
    
    func createDemoData() {
        let settings = getAppSettings()
        guard settings.isFirstLaunch else { return }
        
        // Create demo tasks
        let demoTasks = [
            ("Morning Exercise", "30 minutes of cardio", "health", "high", "daily"),
            ("Read a Book", "Read for 20 minutes", "learning", "medium", "daily"),
            ("Clean Kitchen", "Wash dishes and clean counters", "home", "low", "none"),
            ("Team Meeting", "Weekly team sync", "work", "high", "weekly"),
            ("Call Mom", "Weekly check-in call", "social", "medium", "weekly")
        ]
        
        for (title, description, category, priority, recurrence) in demoTasks {
            _ = createTask(title: title, description: description, category: category, priority: priority, recurrenceType: recurrence)
        }
        
        // Create some demo sweets
        for _ in 0..<5 {
            createRandomSweet()
        }
        
        // Mark as not first launch
        settings.isFirstLaunch = false
        save()
    }
    
    // MARK: - Data Management
    
    func clearAllData() {
        let entities = ["Task", "Sweet", "CompletionHistory", "Streak", "AppSettings"]
        
        for entityName in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error clearing \(entityName): \(error)")
            }
        }
        
        save()
    }
}
