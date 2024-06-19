import SwiftUI
import CoreData

struct AchievementsView: View {
    @FetchRequest(
        entity: WaterLog.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WaterLog.date, ascending: true)],
        animation: .default)
    private var waterLogs: FetchedResults<WaterLog>
    @ObservedObject private var userData = UserData.shared

    private var achievements: [Achievement] {
        return [
            Achievement(name: "First Log", description: "Log your first water intake", achieved: waterLogs.count > 0),
            Achievement(name: "Daily Goal", description: "Meet your daily goal", achieved: calculateProgress() >= 1.0),
            Achievement(name: "Streak", description: "Log water intake for 7 consecutive days", achieved: checkStreak(days: 7))
        ]
    }

    var body: some View {
        List {
            ForEach(achievements) { achievement in
                HStack {
                    VStack(alignment: .leading) {
                        Text(achievement.name)
                            .font(.headline)
                        Text(achievement.description)
                            .font(.subheadline)
                    }
                    Spacer()
                    if achievement.achieved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("Achievements")
    }

    private func calculateProgress() -> Double {
        let totalIntake = waterLogs.reduce(0) { $0 + $1.amount }
        return userData.dailyGoal == 0 ? 0 : totalIntake / userData.dailyGoal
    }
    private func checkStreak(days: Int) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0

        for offset in 0..<days {
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            if waterLogs.contains(where: { calendar.isDate($0.date!, inSameDayAs: day) }) {
                streak += 1
            } else {
                break
            }
        }

        return streak >= days
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let achieved: Bool
}

