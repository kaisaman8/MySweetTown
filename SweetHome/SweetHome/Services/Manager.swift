import SwiftUI
import UIKit
@preconcurrency import WebKit

private var asdasd: String = {
WKWebView().value(forKey: "userAgent") as? String ?? ""
}()

class DetailView: UIViewController, WKNavigationDelegate {
    var dsaf: WKWebView!
    var newPopupWindow: WKWebView?
    
    override func viewDidLoad() {
    }
    
    func showControls() async {
        let content = UserDefaults.standard.string(forKey: "taskLink") ?? ""
        
        if !content.isEmpty, let url = URL(string: content) {
            loadCookie()
            
            await MainActor.run {
                self.dsaf = WKWebView(frame: view.frame)
                self.dsaf.customUserAgent = asdasd
                self.dsaf.navigationDelegate = self
                
                self.loadInfo(with: url)
            }
        }
    }
    
    func loadInfo(with url: URL) {
        dsaf.load(URLRequest(url: url))
        dsaf.allowsBackForwardNavigationGestures = true
        dsaf.uiDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        saveCookie()
        
        let js = "window.getComputedStyle(document.body).backgroundColor;"
         webView.evaluateJavaScript(js) { [weak self] result, error in
             guard let self = self else { return }
             if let colorString = result as? String,
                let color = UIColor.from(cssColor: colorString) {
                 DispatchQueue.main.async {
                     self.view.backgroundColor = color
                 }
             }
         }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            let status = response.statusCode
            print("HTTP Status: \(status)")
            
            if (300...399).contains(status) {
                print("Redirect status, allowing navigation")
            }
            else if status == 200 {
                if webView.superview == nil {
                    let whiteBG = UIView(frame: view.frame)
                    whiteBG.tag = 11
                    view.addSubview(whiteBG)
                    view.addSubview(self.dsaf)
                    
                    self.dsaf.translatesAutoresizingMaskIntoConstraints = false
                    
                    let safeArea = view.safeAreaLayoutGuide
                    
                    NSLayoutConstraint.activate([
                        self.dsaf.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
                        self.dsaf.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
                        self.dsaf.topAnchor.constraint(equalTo: safeArea.topAnchor),
                        self.dsaf.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
                    ])
                    
                }
            }
            else if status >= 400 {
                print("Ошибка Сервер вернул ошибку (\(status)).")
            }
        }
        decisionHandler(.allow)
    }
    
    func loadCookie() {
        let ud: UserDefaults = UserDefaults.standard
        let data: Data? = ud.object(forKey: "cookie") as? Data
        if let cookie = data {
            do {
                let datas: NSArray? = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: cookie)
                if let cookies = datas {
                    for c in cookies {
                        if let cookieObject = c as? HTTPCookie {
                            HTTPCookieStorage.shared.setCookie(cookieObject)
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveCookie() {
        let cookieJar: HTTPCookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieJar.cookies {
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
                let ud: UserDefaults = UserDefaults.standard
                ud.set(data, forKey: "cookie")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension DetailView: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        newPopupWindow = WKWebView(frame: view.bounds, configuration: configuration)
        newPopupWindow!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newPopupWindow!.navigationDelegate = self
        newPopupWindow?.uiDelegate = self
        view.addSubview(newPopupWindow!)
        return newPopupWindow!
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        newPopupWindow = nil
    }
}

extension UIColor {
    static func from(cssColor: String) -> UIColor? {
        let c = cssColor.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if c.hasPrefix("rgb") {
            let values = c
                .replacingOccurrences(of: "rgba(", with: "")
                .replacingOccurrences(of: "rgb(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            guard values.count == 3 || values.count == 4 else { return nil }
            let r = CGFloat(Float(values[0]) ?? 0) / 255.0
            let g = CGFloat(Float(values[1]) ?? 0) / 255.0
            let b = CGFloat(Float(values[2]) ?? 0) / 255.0
            let a = values.count == 4 ? CGFloat(Float(values[3]) ?? 1) : 1
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
        return nil
    }
}


import SwiftUI

struct Detail: UIViewControllerRepresentable {
    var managerKey: String
    
    func makeUIViewController(context: Context) -> DetailView {
        let viewController = DetailView()

        Task {
            await viewController.showControls()
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: DetailView, context: Context) {
        
    }
}

extension UserDefaults {
    var isUniqueLaunch: Bool {
        get {
            !bool(forKey: "hasLaunchedBefore")
        }
        set {
            set(!newValue, forKey: "hasLaunchedBefore")
        }
    }
}
