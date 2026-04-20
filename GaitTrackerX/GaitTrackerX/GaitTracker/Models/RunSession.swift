import Foundation
import Combine

struct RunRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let distance: Float
    let averageCadence: Int
    let averageStrideLength: Float
    let dominantStrikeType: Int   // raw UInt8 value of StrikeType
    let stepCount: Int

    var strikeType: StrikeType {
        StrikeType(rawValue: UInt8(dominantStrikeType)) ?? .midfoot
    }

    var distanceFormatted: String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.2f km", distance / 1000)
        }
    }

    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class RunSession: ObservableObject {
    @Published var isActive = false
    @Published var isPaused = false
    @Published var metrics = GaitMetrics()

    private var startTime: Date?
    private var pausedDuration: TimeInterval = 0
    private var pauseStart: Date?
    private var timer: Timer?

    // Strike type tracking for dominant strike calculation
    private var heelCount = 0
    private var midfootCount = 0
    private var forefootCount = 0
    private var cadenceReadings: [Int] = []

    func start() {
        isActive = true
        isPaused = false
        startTime = Date()
        pausedDuration = 0
        metrics = GaitMetrics()
        heelCount = 0
        midfootCount = 0
        forefootCount = 0
        cadenceReadings = []

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDuration()
        }
    }

    func pause() {
        isPaused = true
        pauseStart = Date()
        timer?.invalidate()
    }

    func resume() {
        isPaused = false
        if let pauseStart = pauseStart {
            pausedDuration += Date().timeIntervalSince(pauseStart)
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDuration()
        }
    }

    func stop() -> RunRecord? {
        timer?.invalidate()
        isActive = false
        isPaused = false

        guard let startTime = startTime, metrics.stepCount > 0 else { return nil }

        let totalDuration = Date().timeIntervalSince(startTime) - pausedDuration
        let avgCadence = cadenceReadings.isEmpty ? 0 : cadenceReadings.reduce(0, +) / cadenceReadings.count
        let dominantStrike = dominantStrikeType()

        return RunRecord(
            id: UUID(),
            date: startTime,
            duration: totalDuration,
            distance: metrics.distance,
            averageCadence: avgCadence,
            averageStrideLength: metrics.distance / max(Float(metrics.stepCount), 1),
            dominantStrikeType: Int(dominantStrike.rawValue),
            stepCount: metrics.stepCount
        )
    }

    func updateMetrics(_ newMetrics: GaitMetrics) {
        metrics = newMetrics
        cadenceReadings.append(newMetrics.cadence)

        switch newMetrics.strikeType {
        case .heel:     heelCount += 1
        case .midfoot:  midfootCount += 1
        case .forefoot: forefootCount += 1
        }
    }

    private func updateDuration() {
        guard let startTime = startTime else { return }
        metrics.duration = Date().timeIntervalSince(startTime) - pausedDuration
    }

    private func dominantStrikeType() -> StrikeType {
        if heelCount >= midfootCount && heelCount >= forefootCount { return .heel }
        if forefootCount >= midfootCount && forefootCount >= heelCount { return .forefoot }
        return .midfoot
    }
}
