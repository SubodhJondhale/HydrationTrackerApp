import SwiftUI
import Charts
struct ChartView: View {
    var waterLogs: [WaterLog]
    var selectedTab: Int

    var body: some View {
        let data = generateChartData()
        Chart(data) { log in
            BarMark(
                x: .value("Date", log.date),
                y: .value("Amount", log.amount)
            )
        }
    }

    private func generateChartData() -> [ChartLog] {
        var chartData: [ChartLog] = []
        let calendar = Calendar.current

        switch selectedTab {
        case 0: // Day
            let today = calendar.startOfDay(for: Date())
            let logsForDay = waterLogs.filter { calendar.isDate($0.date!, inSameDayAs: today) }
            for log in logsForDay {
                chartData.append(ChartLog(date: log.date!, amount: log.amount))
            }
        case 1: // Week
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            for dayOffset in 0..<7 {
                let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
                let logsForDay = waterLogs.filter { calendar.isDate($0.date!, inSameDayAs: date) }
                let totalAmount = logsForDay.reduce(0) { $0 + $1.amount }
                chartData.append(ChartLog(date: date, amount: totalAmount))
            }
        case 2: // Month
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
            for day in range {
                let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
                let logsForDay = waterLogs.filter { calendar.isDate($0.date!, inSameDayAs: date) }
                let totalAmount = logsForDay.reduce(0) { $0 + $1.amount }
                chartData.append(ChartLog(date: date, amount: totalAmount))
            }
        default:
            break
        }

        return chartData
    }
}






