import SwiftUI

struct LogListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: WaterLog.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WaterLog.date, ascending: true)],
        animation: .default)
    private var waterLogs: FetchedResults<WaterLog>

    @State private var showingAddLogView = false
    @State private var showAlert = false
    @ObservedObject private var userData = UserData.shared

    var body: some View {
        NavigationView {
            ZStack {
                Image("AppBackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.7)
                    .scaleEffect(2)

                VStack {
                    ProgressCircle(progress: calculateProgress())
                        .frame(height: 200)
                        .padding()

                    List {
                        ForEach(waterLogs) { log in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(log.date!, formatter: itemFormatter)")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Amount: \(log.amount, specifier: "%.2f") ml")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                    .opacity(0.7)
                            }
                            .padding(.vertical, 5)
                        }
                        .onDelete(perform: deleteLogs)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Hydration Tracker")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            EditButton()
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingAddLogView.toggle()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                        }
                        ToolbarItem(placement: .bottomBar) {
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                        }
                        ToolbarItem(placement: .bottomBar) {
                            NavigationLink(destination: AchievementsView()) {
                                Image(systemName: "star.fill")
                                    .font(.title)
                                    .foregroundColor( Color(red: 53/255, green: 152/255, blue: 219/255))
                            }
                        }
                        ToolbarItem(placement: .bottomBar) {
                            NavigationLink(destination: HistoryView(waterLogs: .constant(Array(waterLogs)))) {
                                Image(systemName: "clock.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddLogView) {
                    AddLogView().environment(\.managedObjectContext, viewContext)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Congratulations!"),
                    message: Text("You've achieved your daily goal."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                if calculateProgress() >= 1.0 {
                    showAlert = true
                }
            }
        }
    }

    private func calculateProgress() -> Double {
        let totalAmount = waterLogs.reduce(0) { $0 + $1.amount }
        return totalAmount / userData.dailyGoal
    }

    private func deleteLogs(offsets: IndexSet) {
        withAnimation {
            offsets.map { waterLogs[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete log: \(error.localizedDescription)")
            }
        }
    }
}

