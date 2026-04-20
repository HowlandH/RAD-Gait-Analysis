import Foundation

enum StrikeType: UInt8, CustomStringConvertible {
    case heel = 0
    case midfoot = 1
    case forefoot = 2

    var description: String {
        switch self {
        case .heel:     return "Heel"
        case .midfoot:  return "Midfoot"
        case .forefoot: return "Forefoot"
        }
    }

    var advice: String {
        switch self {
        case .heel:     return "High impact - try landing with foot under hips"
        case .midfoot:  return "Good form - keep it up!"
        case .forefoot: return "Low impact - great for speed"
        }
    }
}

struct GaitMetrics {
    var strideLength: Float = 0.0       // meters
    var cadence: Int = 0                // steps/min
    var strikeType: StrikeType = .midfoot
    var batteryLevel: Int = 100         // percentage
    var distance: Float = 0.0          // cumulative meters
    var duration: TimeInterval = 0      // seconds
    var stepCount: Int = 0

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

    var paceFormatted: String {
        guard distance > 0, duration > 0 else { return "--:--" }
        let paceSeconds = duration / Double(distance / 1000) // seconds per km
        let minutes = Int(paceSeconds) / 60
        let seconds = Int(paceSeconds) % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}
