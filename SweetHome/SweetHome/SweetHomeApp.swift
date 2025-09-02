//
//  SweetHomeApp.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI

@main
struct SweetHomeApp: App {
    let coreDataManager = CoreDataManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingManager.isOnboardingCompleted {
                    MainTabView()
                        .environment(\.managedObjectContext, coreDataManager.context)
                        .environmentObject(coreDataManager)
                        .onAppear {
                            coreDataManager.createDemoData()
                        }
                } else {
                    OnboardingView(isOnboardingCompleted: $onboardingManager.isOnboardingCompleted)
                }
            }
            .environmentObject(onboardingManager)
        }
    }
}
