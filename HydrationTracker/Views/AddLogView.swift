import SwiftUI

struct AddLogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var amount: String = ""
    @State private var selectedUnit: Unit = .glass // Default selection

    var body: some View {

        NavigationView {
          
            VStack {
                Spacer()
                Text("Add Water Log")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .padding()

                HStack {
                    Spacer()
                    Image(systemName: selectedUnit.symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding()

                Form {
                    Section(header: Text("Select Unit").font(.headline).foregroundColor(.blue)) {
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(Unit.allCases) { unit in
                                HStack {
                                    Image(systemName: unit.symbolName)
                                        .frame(width: 24, height: 24)
                                    Text("\(unit.rawValue.capitalized) (\(unit.quantity) ml)")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding(.leading, 8)
                                }
                                .tag(unit)
                                .background(unit == selectedUnit ? Color.blue.opacity(0.2) : Color.clear)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 120)
                        .clipped()
                    }

                    Section(header: Text("Enter Amount").font(.headline).foregroundColor(.blue)) {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }

                    Section {
                        Button(action: addLog) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Log")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding()

                Spacer()
            }
            .navigationBarTitle("Add Water Log", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func addLog() {
        var finalAmount = Double(amount) ?? 0.0
        if finalAmount == 0.0 {
            finalAmount = Double(selectedUnit.quantity)
        } else {
            finalAmount *= Double(selectedUnit.quantity)
        }

        let newLog = WaterLog(context: viewContext)
        newLog.id = UUID()
        newLog.date = Date()
        newLog.amount = finalAmount

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save water log: \(error.localizedDescription)")
        }
    }

    enum Unit: String, CaseIterable, Identifiable {
        case glass, bottle, cup

        var id: String { self.rawValue }

        var symbolName: String {
            switch self {
            case .glass:
                return "wineglass.fill"
            case .bottle:
                return "waterbottle.fill"
            case .cup:
                return "takeoutbag.and.cup.and.straw.fill"
            }
        }

        var quantity: Int {
            switch self {
            case .glass:
                return 250
            case .bottle:
                return 500
            case .cup:
                return 100 
            }
        }
    }
}

