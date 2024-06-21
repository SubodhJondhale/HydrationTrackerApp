import SwiftUI
import Charts

struct HistoryView: View {
    @Binding var waterLogs: [WaterLog]
    @State private var selectedTab: Int = 0
    @State private var selectedDate: Date? = nil

    var body: some View {
        VStack {

            Picker("View", selection: $selectedTab) {
                Text("Day").tag(0)
                Text("Week").tag(1)
                Text("Month").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            ChartView(waterLogs: waterLogs, selectedTab: selectedTab)
                .frame(height: 200)
                .padding()

            ScrollView {
                ForEach(groupedLogs.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text("\(itemFormatter.string(from: date))")) {
                        ForEach(groupedLogs[date]!) { log in
                            VStack(alignment: .leading) {
                                Text("Amount: \(log.amount, specifier: "%.2f") ml")
                                    .font(.subheadline)

                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
        }
        .navigationTitle("Hydration History")
    }

    private var groupedLogs: [Date: [WaterLog]] {
        Dictionary(grouping: waterLogs) { log in
            Calendar.current.startOfDay(for: log.date!)
        }
    }

}





