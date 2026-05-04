import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var bleManager: BLEManager
    @StateObject private var session = RunSession()
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Status bar
                    StatusBar(bleManager: bleManager)

                    // Cadence hero card
                    CadenceHeroCard(
                        cadence: session.isActive ? session.metrics.cadence : bleManager.metrics.cadence,
                        color: cadenceColor
                    )

                    // Stride + Strike
                    HStack(spacing: 14) {
                        SmallMetricCard(
                            title: "Stride",
                            value: String(format: "%.2f", session.isActive ? session.metrics.strideLength : bleManager.metrics.strideLength),
                            unit: "m",
                            color: .blue,
                            icon: "ruler.fill"
                        )
                        StrikeCard(strikeType: session.isActive ? session.metrics.strikeType : bleManager.metrics.strikeType)
                    }

                    // Distance + Time
                    HStack(spacing: 14) {
                        SmallMetricCard(
                            title: "Distance",
                            value: session.isActive ? session.metrics.distanceFormatted : "0 m",
                            unit: "",
                            color: .purple,
                            icon: "map.fill"
                        )
                        SmallMetricCard(
                            title: "Time",
                            value: session.isActive ? session.metrics.durationFormatted : "00:00",
                            unit: "",
                            color: .orange,
                            icon: "timer"
                        )
                    }

                    // Pace (only during active run)
                    if session.isActive {
                        SmallMetricCard(
                            title: "Pace",
                            value: session.metrics.paceFormatted,
                            unit: "",
                            color: .teal,
                            icon: "speedometer"
                        )
                    }

                    // Run controls
                    RunControlButtons(session: session)
                        .padding(.top, 4)
                }
                .padding()
            }
            .background(Color(.init(white: 0.96, alpha: 1)))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Disconnect") {
                        bleManager.disconnect()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .onChange(of: bleManager.metrics.stepCount) { _, _ in
            if session.isActive {
                session.updateMetrics(bleManager.metrics)
            }
        }
    }

    private var cadenceColor: Color {
        let cadence = session.isActive ? session.metrics.cadence : bleManager.metrics.cadence
        if cadence == 0 { return .gray }
        if cadence < 160 { return .red }
        if cadence < 170 { return .orange }
        if cadence <= 180 { return .green }
        return .blue
    }
}

// MARK: - Status Bar

struct StatusBar: View {
    let bleManager: BLEManager

    private var batteryIcon: String {
        let level = bleManager.metrics.batteryLevel
        if level > 75 { return "battery.100" }
        if level > 50 { return "battery.75" }
        if level > 25 { return "battery.50" }
        if level > 10 { return "battery.25" }
        return "battery.0"
    }

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(bleManager.isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(bleManager.isConnected ? "Connected" : "Disconnected")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(bleManager.isConnected ? .green : .red)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(bleManager.isConnected ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
            )

            Spacer()

            Label("\(bleManager.metrics.batteryLevel)%", systemImage: batteryIcon)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(bleManager.metrics.batteryLevel < 20 ? .red : .secondary)
        }
    }
}

// MARK: - Cadence Hero Card

struct CadenceHeroCard: View {
    let cadence: Int
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.25), color.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Cadence", systemImage: "metronome.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                    Spacer()
                    Image(systemName: "waveform.path.ecg")
                        .font(.title2)
                        .foregroundColor(color.opacity(0.4))
                }

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(cadence)")
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                        .foregroundColor(color)
                    Text("steps/min")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 6)
                }
            }
            .padding(20)
        }
        .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Small Metric Card

struct SmallMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Strike Card

struct StrikeCard: View {
    let strikeType: StrikeType

    private var color: Color {
        switch strikeType {
        case .heel:     return .red
        case .midfoot:  return .green
        case .forefoot: return .blue
        }
    }

    private var icon: String {
        switch strikeType {
        case .heel:     return "arrow.down.to.line"
        case .midfoot:  return "checkmark.circle.fill"
        case .forefoot: return "arrow.up.to.line"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Strike")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(strikeType.description)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text(strikeType.advice)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Run Control Buttons

struct RunControlButtons: View {
    @ObservedObject var session: RunSession
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        HStack(spacing: 12) {
            if !session.isActive {
                ControlButton(label: "Start Run", icon: "play.fill", color: .green) {
                    session.start()
                }
            } else {
                if session.isPaused {
                    ControlButton(label: "Resume", icon: "play.fill", color: .green) {
                        session.resume()
                    }
                } else {
                    ControlButton(label: "Pause", icon: "pause.fill", color: .orange) {
                        session.pause()
                    }
                }
                ControlButton(label: "Stop", icon: "stop.fill", color: .red) {
                    if let record = session.stop() {
                        dataManager.save(record)
                    }
                }
            }
        }
    }
}

struct ControlButton: View {
    let label: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(label)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [color, color.opacity(0.75)], startPoint: .top, endPoint: .bottom)
            )
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(color: color.opacity(0.35), radius: 6, x: 0, y: 3)
        }
    }
}
