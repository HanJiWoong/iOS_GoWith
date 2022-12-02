//
//  AppDelegate.swift
//  GWith
//
//  Created by 한지웅 on 2022/09/20.
//

import UIKit
import WebViewWarmUper
import FirebaseCore
import FirebaseMessaging
import NotificationCenter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        WKWebViewWarmUper.shared.prepare()
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("알림 등록이 완료되었습니다.")
            }
        }
        application.registerForRemoteNotifications()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate:UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        onBroadcastNoti(userInfo: userInfo)
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

       // With swizzling disabled you must let Messaging know about the message, for Analytics
       // Messaging.messaging().appDidReceiveMessage(userInfo)

//           // Print message ID.
//           if let messageID = userInfo[gcmMessageIDKey] {
//             print("Message ID: \(messageID)")
//           }

        onBroadcastNoti(userInfo: userInfo)
    
       // Print full message.
       print(userInfo)

       // Change this to your preferred presentation option
       completionHandler([])
    }
    
    func onBroadcastNoti(userInfo:[AnyHashable : Any]) {
        let interfaceName = userInfo[PushNotiDataKeys.NotiKeyFuncName] as? String
        let alarmType = userInfo[PushNotiDataKeys.NotiKeyAlarmType] as? String
        let location = userInfo[PushNotiDataKeys.NotiKeyLocation] as? String
        let memberName = userInfo[PushNotiDataKeys.NotiKeyMemberName] as? String
        let rideManagerPhone = userInfo[PushNotiDataKeys.NotiKeyRideManagerPhone] as? String
        let lineResultId = userInfo[PushNotiDataKeys.NotiKeyLineResultId] as? String
        
        let notiData = PushNotiDataModel(interfaceName: interfaceName, alarmType: alarmType, locationName: location, memberName: memberName, rideManagerPhone: rideManagerPhone,lineResultId: lineResultId)
        
        NotificationCenter.default.post(name: Notification.Name(NotificationName.NotificationNamePushData), object: notiData)
        
        
    }
    
}

extension AppDelegate:MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token :\(fcmToken ?? "")")
        UserDefaults.standard.set(fcmToken, forKey: StoreKeys.KeysFCMToken)
    }
}
