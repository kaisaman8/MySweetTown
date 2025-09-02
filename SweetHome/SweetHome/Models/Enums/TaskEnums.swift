//
//  TaskEnums.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import Foundation

enum TaskPriority: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
    
    var color: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        }
    }
    
    var iconName: String {
        switch self {
        case .low:
            return "arrow.down.circle"
        case .medium:
            return "minus.circle"
        case .high:
            return "arrow.up.circle"
        }
    }
}

enum RecurrenceType: String, CaseIterable {
    case none = "none"
    case daily = "daily"
    case weekdays = "weekdays"
    case weekly = "weekly"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .none:
            return "No Repeat"
        case .daily:
            return "Daily"
        case .weekdays:
            return "Weekdays"
        case .weekly:
            return "Weekly"
        case .custom:
            return "Custom"
        }
    }
    
    var iconName: String {
        switch self {
        case .none:
            return "circle"
        case .daily:
            return "repeat"
        case .weekdays:
            return "calendar.badge.clock"
        case .weekly:
            return "calendar"
        case .custom:
            return "gear"
        }
    }
}

enum TaskCategory: String, CaseIterable {
    case work = "work"
    case personal = "personal"
    case health = "health"
    case learning = "learning"
    case home = "home"
    case social = "social"
    case finance = "finance"
    case hobby = "hobby"
    
    var displayName: String {
        switch self {
        case .work:
            return "Work"
        case .personal:
            return "Personal"
        case .health:
            return "Health"
        case .learning:
            return "Learning"
        case .home:
            return "Home"
        case .social:
            return "Social"
        case .finance:
            return "Finance"
        case .hobby:
            return "Hobby"
        }
    }
    
    var iconName: String {
        switch self {
        case .work:
            return "briefcase"
        case .personal:
            return "person"
        case .health:
            return "heart"
        case .learning:
            return "book"
        case .home:
            return "house"
        case .social:
            return "person.2"
        case .finance:
            return "dollarsign.circle"
        case .hobby:
            return "gamecontroller"
        }
    }
    
    var color: String {
        switch self {
        case .work:
            return "blue"
        case .personal:
            return "purple"
        case .health:
            return "red"
        case .learning:
            return "green"
        case .home:
            return "orange"
        case .social:
            return "pink"
        case .finance:
            return "yellow"
        case .hobby:
            return "cyan"
        }
    }
}
