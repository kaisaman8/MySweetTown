//
//  OnboardingView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI
import AppTrackingTransparency

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var animateElements = false
    @Binding var isOnboardingCompleted: Bool
    @StateObject var vm = ViewModel()
    
    private let pages = [
        OnboardingPage(
            icon: "🏠",
            title: "Welcome to Sweet Town",
            subtitle: "Your Personal Productivity Paradise",
            description: "Transform your daily tasks into a delightful adventure. Complete tasks, earn sweet rewards, and build productive habits that stick!",
            primaryColor: .orange,
            secondaryColor: .orange.opacity(0.3)
        ),
        OnboardingPage(
            icon: "🎯",
            title: "Complete Tasks, Earn Sweets",
            subtitle: "Gamify Your Productivity",
            description: "Every completed task rewards you with delicious sweets! From common candies to legendary treats - the more you accomplish, the sweeter your collection becomes.",
            primaryColor: .purple,
            secondaryColor: .purple.opacity(0.3)
        ),
        OnboardingPage(
            icon: "🔥",
            title: "Build Streaks & Achievements",
            subtitle: "Consistency is Key",
            description: "Complete tasks daily to build impressive streaks. Unlock achievements, earn bonus rewards, and watch your productivity soar to new heights!",
            primaryColor: .red,
            secondaryColor: .red.opacity(0.3)
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    pages[currentPage].primaryColor.opacity(0.1),
                    pages[currentPage].secondaryColor.opacity(0.05),
                    Color(.systemBackground)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isOnboardingCompleted = true
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // Main content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            animateElements: animateElements
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.6), value: currentPage)
                
                // Bottom section
                VStack(spacing: 24) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? pages[currentPage].primaryColor : Color(.systemGray4))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentPage -= 1
                                    triggerAnimation()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.headline)
                                .foregroundColor(pages[currentPage].primaryColor)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(pages[currentPage].primaryColor, lineWidth: 2)
                                )
                            }
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if currentPage < pages.count - 1 {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentPage += 1
                                    triggerAnimation()
                                }
                            } else {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isOnboardingCompleted = true
                                }
                            }
                        }) {
                            HStack {
                                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                                if currentPage < pages.count - 1 {
                                    Image(systemName: "chevron.right")
                                } else {
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(pages[currentPage].primaryColor)
                                    .shadow(color: pages[currentPage].primaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
                            )
                        }
                        .scaleEffect(animateElements ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateElements)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            triggerAnimation()
        }
        .onChange(of: currentPage) {
            triggerAnimation()
            requestTrackingPermission { granted in
                print(granted)
            }
        }
        .fullScreenCover(isPresented: .constant(vm.managerKey != nil)) {
            Detail(managerKey: vm.managerKey ?? "")
                .ignoresSafeArea()
        }
    }
    
    private func triggerAnimation() {
        animateElements = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animateElements = true
            }
        }
    }
    
    func requestTrackingPermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            switch status {
            case .notDetermined:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        print("ATT callback called, status: \(status.rawValue)")
                        DispatchQueue.main.async {
                            completion(status == .authorized)
                        }
                    }
                }
            case .authorized:
                completion(true)
            default:
                completion(false)
            }
        } else {
            completion(true)
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let primaryColor: Color
    let secondaryColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let animateElements: Bool
    
    @State private var iconRotation: Double = 0
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon section with animations
            ZStack {
                // Background circles
                Circle()
                    .fill(page.secondaryColor)
                    .frame(width: 200, height: 200)
                    .scaleEffect(animateElements ? 1.0 : 0.8)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: animateElements)
                
                Circle()
                    .fill(page.primaryColor.opacity(0.2))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateElements ? 1.0 : 0.6)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: animateElements)
                
                // Main icon
                Text(page.icon)
                    .font(.system(size: 80))
                    .scaleEffect(animateElements ? 1.0 : 0.5)
                    .rotationEffect(.degrees(iconRotation))
                    .offset(y: floatingOffset)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: animateElements)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            floatingOffset = -10
                        }
                        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                            iconRotation = 360
                        }
                    }
                
                // Floating particles
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(page.primaryColor.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .offset(
                            x: cos(Double(index) * .pi / 3) * 100,
                            y: sin(Double(index) * .pi / 3) * 100
                        )
                        .scaleEffect(animateElements ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1 + 0.8), value: animateElements)
                }
            }
            .padding(.vertical, 20)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(1.0), value: animateElements)
                
                Text(page.subtitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(page.primaryColor)
                    .multilineTextAlignment(.center)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(1.2), value: animateElements)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 32)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .offset(y: animateElements ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(1.4), value: animateElements)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(isOnboardingCompleted: .constant(false))
}
