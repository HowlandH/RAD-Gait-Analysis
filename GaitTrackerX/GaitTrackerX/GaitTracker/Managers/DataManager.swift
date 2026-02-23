import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var runHistory: [RunRecord] = []

    private let saveKey = "gait_run_history"

    init() {
        load()
    }

    func save(_ record: RunRecord) {
        runHistory.insert(record, at: 0) // newest first
        persist()
    }

    func delete(at offsets: IndexSet) {
        runHistory.remove(atOffsets: offsets)
        persist()
    }

    func exportCSV() -> String {
        var csv = "Date,Duration,Distance(m),Cadence(steps/min),Stride Length(m),Strike Type,Steps\n"
        for run in runHistory {
            csv += "\(run.dateFormatted),\(run.durationFormatted),\(String(format: "%.1f", run.distance)),\(run.averageCadence),\(String(format: "%.2f", run.averageStrideLength)),\(run.strikeType.description),\(run.stepCount)\n"
        }
        return csv
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(runHistory) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([RunRecord].self, from: data) {
            runHistory = decoded
        }
    }
}
