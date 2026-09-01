import UIKit
import Flutter
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var notificationsChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAbMnYtf4CvJHr6GeQKO95zOpkTi-v9h7g")
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "trusty/notifications",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        guard call.method == "clearChatNotification" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard
          let arguments = call.arguments as? [String: Any],
          let chatId = arguments["chatId"] as? String,
          !chatId.isEmpty
        else {
          result(
            FlutterError(
              code: "invalid_chat_id",
              message: "A non-empty chatId is required.",
              details: nil
            )
          )
          return
        }

        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
          let identifiers = notifications.compactMap { notification -> String? in
            let notificationChatId = notification.request.content.userInfo["chatId"] as? String
            return notificationChatId == chatId ? notification.request.identifier : nil
          }
          if !identifiers.isEmpty {
            UNUserNotificationCenter.current().removeDeliveredNotifications(
              withIdentifiers: identifiers
            )
          }
          DispatchQueue.main.async {
            result(nil)
          }
        }
      }
      notificationsChannel = channel
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
