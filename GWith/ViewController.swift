//
//  ViewController.swift
//  GWith
//
//  Created by 한지웅 on 2022/09/20.
//

import UIKit
import WebKit
import WebViewWarmUper

class ViewController: UIViewController {

    @IBOutlet weak var mMainView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let contentController = WKUserContentController()
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = contentController
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.allowsInlineMediaPlayback = false
        configuration.allowsAirPlayForMediaPlayback = false
        configuration.allowsPictureInPictureMediaPlayback = true
        
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeCookies])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set, modifiedSince: date as Date, completionHandler:{ })
        print("delete cache data")
        /* 모든 열어본 페이지에 대한 데이터를 모두 삭제 */
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: {
            (records) -> Void in
            for record in records{
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("delete cache data")
            }
        })
        
//        let mainWebView = WKWebView(frame: mMainView.bounds, configuration: configuration)
        let mainWebView = WKWebViewWarmUper.shared.dequeue()
        mainWebView.uiDelegate = self
        mainWebView.navigationDelegate = self
        mainWebView.scrollView.bounces = false
        
        
        mMainView.addSubview(mainWebView)
        setAutoLayout(from: mainWebView, to: mMainView)
        
        let components = URLComponents(string: "https://app.gwith.co.kr")
        
        let request = URLRequest(url: (components?.url)!)
        

        if #available(iOS 14.0, *) {
            mainWebView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
            mainWebView.configuration.preferences.javaScriptEnabled = true
        }
        
        mainWebView.load(request)
        
    }

    public func setAutoLayout(from:UIView, to: UIView) {
        from.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: from, attribute: .leading, relatedBy: .equal, toItem: to, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .trailing, relatedBy: .equal, toItem: to, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .top, relatedBy: .equal, toItem: to, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .bottom, relatedBy: .equal, toItem: to, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        
        view.layoutIfNeeded()
    }

//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//       insertCSSString(into: webView)
//     }
//
//
//    func insertCSSString(into webView: WKWebView) {
//        let cssString = "body { -webkit-transform: translateZ(0); }"
//        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
//        webView.evaluateJavaScript(jsString, completionHandler: nil)
//     }

}

extension ViewController:WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("\(navigationAction.request.url?.absoluteString ?? "")")
        decisionHandler(.allow)
    }
    
    
    
    
}

extension ViewController:WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async {
        
    }
    
    
}

extension ViewController:WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
    }
}

