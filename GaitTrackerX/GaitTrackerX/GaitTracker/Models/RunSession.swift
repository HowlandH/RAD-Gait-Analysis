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
    var heelStrikes: Int
    var midfootStrikes: Int
    var forefootStrikes: Int

    var strikeType: StrikeType {
        StrikeType(rawValue: UInt8(dominantStrikeType)) ?? .midfoot
    }

    var hasStrikeData: Bool {
        heelStrikes + midfootStrikes + forefootStrikes > 0
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

    // Memberwise init — heelStrikes/midfootStrikes/forefootStrikes default to 0
    init(id: UUID, date: Date, duration: TimeInterval, distance: Float,
         averageCadence: Int, averageStrideLength: Float, dominantStrikeType: Int,
         stepCount: Int, heelStrikes: Int = 0, midfootStrikes: Int = 0, forefootStrikes: Int = 0) {
        self.id = id
        self.date = date
        self.duration = duration
        self.distance = distance
        self.averageCadence = averageCadence
        self.averageStrideLength = averageStrideLength
        self.dominantStrikeType = dominantStrikeType
        self.stepCount = stepCount
        self.heelStrikes = heelStrikes
        self.midfootStrikes = midfootStrikes
        self.forefootStrikes = forefootStrikes
    }

    // Custom decoder — defaults strike counts to 0 for records saved before this field existed
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        date = try c.decode(Date.self, forKey: .date)
        duration = try c.decode(TimeInterval.self, forKey: .duration)
        distance = try c.decode(Float.self, forKey: .distance)
        averageCadence = try c.decode(Int.self, forKey: .averageCadence)
        averageStrideLength = try c.decode(Float.self, forKey: .averageStrideLength)
        dominantStrikeType = try c.decode(Int.self, forKey: .dominantStrikeType)
        stepCount = try c.decode(Int.self, forKey: .stepCount)
        heelStrikes = (try? c.decode(Int.self, forKey: .heelStrikes)) ?? 0
        midfootStrikes = (try? c.decode(Int.self, forKey: .midfootStrikes)) ?? 0
        forefootStrikes = (try? c.decode(Int.self, forKey: .forefootStrikes)) ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case id, date, duration, distance, averageCadence, averageStrideLength
        case dominantStrikeType, stepCount, heelStrikes, midfootStrikes, forefootStrikes
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
            stepCount: metrics.stepCount,
            heelStrikes: heelCount,
            midfootStrikes: midfootCount,
            forefootStrikes: forefootCount
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
