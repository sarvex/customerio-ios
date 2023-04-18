import UIKit
import CioTracking
import CioMessagingInApp
import CioMessagingPushAPN

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var storage = DI.shared.storage
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Register for remote notifications using APN. On successful registration,
        // didRegisterForRemoteNotifications delegate method will be called and it
        // provides a device token. In case, registration fails then
        // didFailToRegisterForRemoteNotifications will be called.
        application.registerForRemoteNotifications()
        initializeCioAndInAppListeners()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func initializeCioAndInAppListeners() {
        // Initialise CustomerIO SDK
        // TODO: - Update this when using local storage for configurations
        CustomerIO.initialize(siteId: Env.customerIOSiteId, apiKey: Env.customerIOApiKey, region: Region.US, configure: { config in
            config.logLevel = .debug
            config.autoTrackScreenViews = true
        })
        
        MessagingInApp.initialize(eventListener: self)
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        storage.deviceToken = String(apnDeviceToken: deviceToken)
        MessagingPush.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        MessagingPush.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}



extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Delegate called when user responds to a notification. Set delegate in
    // application:didFinishLaunchingWithOptions: method.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let handled = MessagingPush.shared.userNotificationCenter(center, didReceive: response,
                                                                  withCompletionHandler: completionHandler)

        // If the Customer.io SDK does not handle the push, it's up to you to handle it and call the
        // completion handler. If the SDK did handle it, it called the completion handler for you.
        if !handled {
            completionHandler()
        }
    }
    
    // OPTIONAL: Delegate method only runs when app is active(foreground). If not implemented or delayed, notification won't show in foreground. App can show notification as sound, badge, or alert..
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        completionHandler([.list, .banner, .badge, .sound])
    }
}

extension AppDelegate: InAppEventListener {
    func messageShown(message: InAppMessage) {
        CustomerIO.shared.track(name: "inapp shown",
                                data: ["delivery-id": message.deliveryId ?? "(none)", "message-id": message.messageId])
    }

    func messageDismissed(message: InAppMessage) {
        CustomerIO.shared.track(name: "inapp dismissed",
                                data: ["delivery-id": message.deliveryId ?? "(none)", "message-id": message.messageId])
    }

    func errorWithMessage(message: InAppMessage) {
        CustomerIO.shared.track(name: "inapp error",
                                data: ["delivery-id": message.deliveryId ?? "(none)", "message-id": message.messageId])
    }

    func messageActionTaken(message: InAppMessage, actionValue: String, actionName: String) {
        CustomerIO.shared.track(name: "inapp action", data: [
            "delivery-id": message.deliveryId ?? "(none)",
            "message-id": message.messageId,
            "action-value": actionValue,
            "action-name": actionName
        ])
    }
}

