//
//  OnboardingManager.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import Foundation

class OnboardingManager: ObservableObject {
    @Published var isOnboardingCompleted: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingCompleted, forKey: "isOnboardingCompleted")
        }
    }
    
    static let shared = OnboardingManager()
    
    private init() {
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
    }
    
    func completeOnboarding() {
        isOnboardingCompleted = true
    }
    
    func resetOnboarding() {
        isOnboardingCompleted = false
    }
}
