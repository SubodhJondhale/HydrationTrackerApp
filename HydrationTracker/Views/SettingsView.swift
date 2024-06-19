import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("theme") private var theme: Int = 0 // 0: Light, 1: Dark
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @State private var genderSelection: Gender = .male
    @State private var weightInput: String = "70"
    @State private var heightInput: String = "170"
    @State private var ageInput: String = "30"
    @State private var dailyGoalCalculated: Double = 0.0
    @State private var notificationTimes: [Date] = []
    @State private var selectedTime = Date()

    @ObservedObject private var userData = UserData.shared

    enum Gender {
        case male, female
    }

    var body: some View {
        Form {
            Section(header: Text("Daily Water Goal")) {
                if dailyGoalCalculated == 0.0 {
                    Text("Calculate your daily goal")
                        .foregroundColor(.secondary)
                } else {
                    Text("Recommended: \(Int(dailyGoalCalculated)) ml")
                        .foregroundColor(.secondary)
                }

                Picker(selection: $genderSelection, label: Text("Gender")) {
                    Text("Male").tag(Gender.male)
                    Text("Female").tag(Gender.female)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                TextField("Weight (kg)", text: $weightInput)
                    .keyboardType(.numberPad)
                    .padding(.horizontal)

                TextField("Height (cm)", text: $heightInput)
                    .keyboardType(.numberPad)
                    .padding(.horizontal)

                TextField("Age", text: $ageInput)
                    .keyboardType(.numberPad)
                    .padding(.horizontal)

                Button(action: calculateDailyGoal) {
                    Text("Calculate")
                }
                .padding(.horizontal)
            }

            Section(header: Text("Current Daily Goal")) {
                Slider(value: $userData.dailyGoal, in: 1000...4000, step: 100)
                    .padding(.horizontal)
                Text("\(Int(userData.dailyGoal)) ml")
                    .padding(.horizontal)
            }
            Section(header: Text("Hydration Notifications")) {
                List {
                    ForEach(notificationTimes.indices, id: \.self) { index in
                        let time = notificationTimes[index]
                        HStack {
                            Text("\(time, formatter: itemFormatter)")
                            Spacer()
                            Button(action: {
                                deleteNotification(at: index)
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete(perform: deleteNotifications)
                }

                HStack {
                    DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()

                    Button(action: addNotification) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            dailyGoalCalculated = userData.dailyGoal
            loadNotificationTimes()
        }
        .onDisappear {
            saveNotificationTimes()
        }
    }

    private func calculateDailyGoal() {
        guard let weight = Double(weightInput),
              let height = Double(heightInput),
              let age = Double(ageInput) else { return }

        switch genderSelection {
        case .male:
            dailyGoalCalculated = (66 + (13.75 * weight) + (5 * height) - (6.76 * age)) * 1.5
        case .female:
            dailyGoalCalculated = (655 + (9.56 * weight) + (1.85 * height) - (4.68 * age)) * 1.5
        }
        userData.dailyGoal = dailyGoalCalculated
    }

    private func addNotification() {
        let newNotificationTime = selectedTime
        notificationTimes.append(newNotificationTime)
        scheduleNotification(at: newNotificationTime)
    }

    private func deleteNotification(at index: Int) {
        let notificationTime = notificationTimes[index]
        notificationTimes.remove(at: index)
        cancelNotification(at: notificationTime)
    }

    private func deleteNotifications(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let notificationTime = notificationTimes[index]
            notificationTimes.remove(at: index)
            cancelNotification(at: notificationTime)
        }
    }

    private func loadNotificationTimes() {
        if let savedTimesData = UserDefaults.standard.data(forKey: "notificationTimes") {
            let decoder = JSONDecoder()
            if let savedTimes = try? decoder.decode([Date].self, from: savedTimesData) {
                notificationTimes = savedTimes
            }
        }
    }

    private func saveNotificationTimes() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(notificationTimes) {
            UserDefaults.standard.set(encoded, forKey: "notificationTimes")
        }
    }

    private func scheduleNotification(at time: Date) {
        guard notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated!"
        content.body = "Don't forget to log your water intake."
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully: \(time)")
            }
        }
    }

    private func cancelNotification(at time: Date) {
        let identifier = "\(time)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

