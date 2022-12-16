//
//  ViewController.swift
//  GWith
//
//  Created by 한지웅 on 2022/09/20.
//

import UIKit
import WebKit
import WebViewWarmUper
import CoreLocation
import CoreNFC

class ViewController: UIViewController {

    @IBOutlet weak var mMainView: UIView!
    var mMainWebView:WKWebView? = nil
    
    var mLocationSevice:LocationService = LocationService()
    var mCurrentLocation:CLLocation? = nil
        
    public func setAutoLayout(from:UIView, to: UIView) {
        from.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.init(item: from, attribute: .leading, relatedBy: .equal, toItem: to, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .trailing, relatedBy: .equal, toItem: to, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .top, relatedBy: .equal, toItem: to, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint.init(item: from, attribute: .bottom, relatedBy: .equal, toItem: to, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        
        view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
//        NFCService.shared.readyService(controller: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveNotification(_:)), name: NSNotification.Name( NotificationName.NotificationNamePushData), object: nil)
        
        mLocationSevice.delegate = self
        mLocationSevice.locationServiceStart()
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let contentController = WKUserContentController()
        contentController.add(self, name: JSRequestInterfaceName.Bridge)
        contentController.add(self, name: JSRequestInterfaceName.NfcLaunch)
        contentController.add(self, name: JSRequestInterfaceName.CurrentLocation)
        contentController.add(self, name: JSRequestInterfaceName.FCMToken)
        contentController.add(self, name: JSRequestInterfaceName.TMap)
        contentController.add(self, name: JSRequestInterfaceName.VersionInfo)
        contentController.add(self, name: JSRequestInterfaceName.PhoneCall)
        contentController.add(self, name: JSRequestInterfaceName.BleBeaconTag)
        contentController.add(self, name: JSRequestInterfaceName.MemberID)
        
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
        /* 모든 열어본 페이지에 대한 데이터를 모두 삭제 */
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: {
            (records) -> Void in
            for record in records{
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("delete cache data")
            }
        })
        
        
        
        mMainWebView = WKWebView(frame: mMainView.bounds, configuration: configuration)
//        let mainWebView = WKWebViewWarmUper.shared.dequeue()
        if let webView = mMainWebView {
            webView.allowsBackForwardNavigationGestures = true
            webView.uiDelegate = self
            webView.navigationDelegate = self
            webView.scrollView.bounces = false
            
            mMainView.addSubview(webView)
            setAutoLayout(from: webView, to: mMainView)
            
            let components = URLComponents(string: "https://dev-app.gwith.co.kr")
            
            var request = URLRequest(url: (components?.url)!)
            request.setValue("dpaxltm1@#", forHTTPHeaderField: "gwithappkey")
            

            if #available(iOS 14.0, *) {
                webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            } else {
                // Fallback on earlier versions
                webView.configuration.preferences.javaScriptEnabled = true
            }
            
            webView.load(request)
        } else {
            print("WebView Load Error")
        }
    }
    
    @objc func didRecieveNotification(_ notificaiton: Notification) {
        let data = notificaiton.object as? PushNotiDataModel
        
//        let inferfaceName = data?.interfaceName
//        let alarmType = data?.alarmType
//        let location = data?.locationName
//        let memberName = data?.memberName
//        let rideManagerPhone = data?.rideManagerPhone
//        let lineResultId = data?.lineResultId
        
        guard let interfaceName = data?.interfaceName else {
            print("인터페이스 이름이 없습니다.")
            return
        }
        
        guard let alarmType = data?.alarmType, let location = data?.locationName else {
            print("알람 타입 또는 로케이션이 들어오지 않았습니다.")
            return
        }
        
        var interfaceParam = NotiJSInterface(alarmType: alarmType, location: location)
        
        switch(interfaceName) {
        case PushNotiInterfaceName.NotiInterfaceNameGetRidingPu :
            guard let memberName = data?.memberName, let rideManagerPhone = data?.rideManagerPhone else {
                print("\(interfaceName)의 파라미터에 문제가 있습니다.")
                return
            }
            
            interfaceParam.memberName = memberName
            interfaceParam.rideManagerPhone = rideManagerPhone
            
            guard let paramData = try? JSONEncoder().encode(interfaceParam) else {
                print("\(interfaceName)의 Json 변환 실패")
                return
            }
            let paramStr = String(decoding:paramData, as: UTF8.self)
            
            notiCommonJSCall(funcName: interfaceName, param: paramStr)
            
        case PushNotiInterfaceName.NotiInterfaceNameGetNotRidingPu :
            guard let memberName = data?.memberName, let rideManagerPhone = data?.rideManagerPhone else {
                print("\(interfaceName)의 파라미터에 문제가 있습니다.")
                return
            }
            
            interfaceParam.memberName = memberName
            interfaceParam.rideManagerPhone = rideManagerPhone
            
            guard let paramData = try? JSONEncoder().encode(interfaceParam) else {
                print("\(interfaceName)의 Json 변환 실패")
                return
            }
            let paramStr = String(decoding:paramData, as: UTF8.self)
            
            notiCommonJSCall(funcName: interfaceName, param: paramStr)
        case PushNotiInterfaceName.NotiInterfaceNameGetNotGettingOffPu :
            guard let memberName = data?.memberName, let rideManagerPhone = data?.rideManagerPhone else {
                print("\(interfaceName)의 파라미터에 문제가 있습니다.")
                return
            }
            
            interfaceParam.memberName = memberName
            interfaceParam.rideManagerPhone = rideManagerPhone
            
            guard let paramData = try? JSONEncoder().encode(interfaceParam) else {
                print("\(interfaceName)의 Json 변환 실패")
                return
            }
            let paramStr = String(decoding:paramData, as: UTF8.self)
            
            notiCommonJSCall(funcName: interfaceName, param: paramStr)
            
        case PushNotiInterfaceName.NotiInterfaceNameGetNotRidingMgDv :
            guard let lineResultId = data?.lineResultId else {
                print("\(interfaceName)의 파라미터에 문제가 있습니다.")
                return
            }
            
            interfaceParam.lineResultId = lineResultId
            
            guard let paramData = try? JSONEncoder().encode(interfaceParam) else {
                print("\(interfaceName)의 Json 변환 실패")
                return
            }
            let paramStr = String(decoding:paramData, as: UTF8.self)
            
            notiCommonJSCall(funcName: interfaceName, param: paramStr)
        case PushNotiInterfaceName.NotiInterfaceNameGetNotGettingOffMgDv :
            guard let lineResultId = data?.lineResultId else {
                print("\(interfaceName)의 파라미터에 문제가 있습니다.")
                return
            }
            
            interfaceParam.lineResultId = lineResultId
            
            guard let paramData = try? JSONEncoder().encode(interfaceParam) else {
                print("\(interfaceName)의 Json 변환 실패")
                return
            }
            let paramStr = String(decoding:paramData, as: UTF8.self)
            
            notiCommonJSCall(funcName: interfaceName, param: paramStr)
        default :
            print("인터페이스 명에 문제가 있습니다.")
        }
    }
    
    private func notiCommonJSCall(funcName:String, param:String) {
        mMainWebView?.evaluateJavaScript("window.PushAlarm.\(funcName)(\'\(param)\')", completionHandler: {(result, error) in
            if let result = result {
                print(result)
            }
        })
    }
}

extension ViewController:WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("\(navigationAction.request.url?.absoluteString ?? "")")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
 
    }
}

extension ViewController:WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default) { (action) in
            completionHandler(false)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            if let text = alert.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    
}

extension ViewController:WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch(message.name) {
        case JSRequestInterfaceName.MemberID:
            print(message.body)
            
            let memberId = message.body
            UserDefaults.standard.set(memberId, forKey: StoreKeys.KeysMemberID)
            
            break
        case JSRequestInterfaceName.NfcLaunch:
            
            break
        case JSRequestInterfaceName.CurrentLocation :
            if let webView = mMainWebView, let updateLocation = mCurrentLocation {
                
                do {
                    let location:LocationModel = .init(latitude: updateLocation.coordinate.latitude, longitude: updateLocation.coordinate.longitude)
                                        
                    guard let locationData = try? JSONEncoder().encode(location) else { return }
                    let locationStr = String(decoding:locationData, as: UTF8.self)
                    
                    webView.evaluateJavaScript("window.IOSInterface.currentLocation(\'\(locationStr)\')", completionHandler: {(result, error) in
                        if let result = result {
                            print(result)
                        }
                    })
                    
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print("WebView Load Error")
            }
        
            break
        case JSRequestInterfaceName.FCMToken:
            if let webView = mMainWebView {
                do {
                    let token:String? = UserDefaults.standard.string(forKey: StoreKeys.KeysFCMToken)
                    
                    if let t = token {
                        let tokenModel:FCMTokenModel = .init(result: true, token: t)
                        
                        guard let tokenData = try? JSONEncoder().encode(tokenModel) else { return }
                        let tokenStr = String(decoding:tokenData, as: UTF8.self)
                        
                        webView.evaluateJavaScript("window.IOSInterface.FCMToken(\'\(tokenStr)\')") { (result, error) in
                            if let result = result {
                                print(result)
                            } else {
                                print(error?.localizedDescription ?? "")
                            }
                        }
                    }
                }
            }
            break
        case JSRequestInterfaceName.TMap :
        
            let body:NSDictionary? = message.body as? NSDictionary
            
            if let data = body {
                let startLong = data.value(forKey: "startLong") as? String
                let startLat = data.value(forKey: "startLat") as? String
                let goalLong = data.value(forKey: "goalLong") as? String
                let goalLat = data.value(forKey: "goalLat") as? String
                
                guard let gLng = goalLong, let gLat = goalLat else {
                    return
                }
                
                var linkUrl:URL? = nil
                
                if let sLng = startLong, let sLat = startLat {
                    linkUrl = URL(string: "tmap://route?startx=\(sLng)&starty=\(sLat)&goalx=\(gLng)&goaly=\(gLat)")
                } else {
                     linkUrl = URL(string: "tmap://route?goalx=\(gLng)&goaly=\(gLat)")
                }
                
                if let url = linkUrl {
                    UIApplication.shared.open(url)
                }
            }
            break
        case JSRequestInterfaceName.VersionInfo :
            if let webView = mMainWebView {
                do {
                    let token:String? = UserDefaults.standard.string(forKey: StoreKeys.KeysFCMToken)
                    
                    if let t = token {
                        
                        guard let dictionary = Bundle.main.infoDictionary,
                            let version = dictionary["CFBundleShortVersionString"] as? String,
                            let build = dictionary["CFBundleVersion"] as? String else {return }
                        
                        let versionInfoModel = VersionInfoModel(osType: "iOS",
                                                                appVersionCode: build,
                                                                appVersionName: version,
                                                                splashID: "1234567890",
                                                                fcmToken: t)
                        
                        
                        guard let versionData = try? JSONEncoder().encode(versionInfoModel) else { return }
                        let versionStr = String(decoding:versionData, as: UTF8.self)
                        
                        webView.evaluateJavaScript("window.NativeInterface.versionInfo(\'\(versionStr)\')") { (result, error) in
                            if let result = result {
                                print(result)
                            } else {
                                print(error?.localizedDescription ?? "")
                            }
                        }
                    }
                }
            }
            
            break
        case JSRequestInterfaceName.PhoneCall :
            print(message.body)
            let phoneNum = message.body
            
            if let url = NSURL(string: "tel://\(phoneNum)") {
                if UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.open(url as URL, options:[:], completionHandler: nil)
                }
            }
                
            break
        case JSRequestInterfaceName.BleBeaconTag :
            if let webView = mMainWebView {
                
                do {
                    var state:BleStateModel?
                                        
                    if BleAdService.shared.mBleState == .poweredOn {
                        state = .init(state: true)
                    } else {
                        state = .init(state:false)
                    }
                    
                    guard let bleStateData = try? JSONEncoder().encode(state) else { return }
                    let bleStateStr = String(decoding:bleStateData, as: UTF8.self)


                    webView.evaluateJavaScript("window.NativeInterface.blueToothState(\'\(bleStateStr)\')", completionHandler: {(result, error) in
                        if let result = result {
                            print(result)
                        }
                        
                        let memberId = UserDefaults.standard.value(forKey: StoreKeys.KeysMemberID)
                        BleAdService.shared.StartService(memberId: memberId as! String)
                    })
                    
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print("WebView Load Error")
            }

            break
        default :
            break
        }
                
    }
    
}

extension ViewController:LocationServiceDelegate {
    func updateCurrentLocation(updateLocation: CLLocation) {
        mCurrentLocation = updateLocation
    }
}
