import Foundation

let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

import SwiftUI

class UserData: ObservableObject {
    @Published var dailyGoal: Double = 2500.0 // Initial value
    static let shared = UserData()
    private init() {}
}



