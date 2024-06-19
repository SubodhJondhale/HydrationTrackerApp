import SwiftUI
import UIKit
import UserNotifications

@main
struct MyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LogListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }

        scheduleCustomReminders()
        return true
    }

    func scheduleCustomReminders() {
        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated!"
        content.body = "Don't forget to log your water intake."

        var dateComponents = DateComponents()
        dateComponents.hour = UserDefaults.standard.integer(forKey: "reminderHour")
        dateComponents.minute = UserDefaults.standard.integer(forKey: "reminderMinute")
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "CustomReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }

        }
    }

}

