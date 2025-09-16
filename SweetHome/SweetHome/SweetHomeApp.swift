import SwiftUI
import AdSupport
import AdjustSdk
import AppTrackingTransparency

@main
struct SweetHomeApp: App {
    let coreDataManager = CoreDataManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
                        .onAppear {
                        }
                }
            }
            .environmentObject(onboardingManager)
        }
    }

}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let adjustHandler = AdjustHandler()
    
    

    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Push permission denied: \(error?.localizedDescription ?? "unknown error")")
            }
        }
        
        let appToken = "a0kdqyqbbda8"
        let environment = ADJEnvironmentProduction
        let config = ADJConfig(appToken: appToken, environment: environment)
        config?.delegate = self.adjustHandler
        Adjust.initSdk(config)
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
}

class AdjustHandler: NSObject, AdjustDelegate {
    var adjustJsonResponse: String? = nil
    var lastAttribution: ADJAttribution?
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        guard let attr = attribution else { return }
        lastAttribution = attr
        if let jsonDict = attr.jsonResponse,
           let data = try? JSONSerialization.data(withJSONObject: jsonDict),
           let jsonString = String(data: data, encoding: .utf8) {
            adjustJsonResponse = jsonString
            print("Adjust jsonResponse ready: \(jsonString)")
            UserDefaults.standard.set(jsonString, forKey: "lastAdjustAttribution")
        } else {
            adjustJsonResponse = nil
            print("Adjust jsonResponse is nil or not a dictionary")
        }
    }
}

