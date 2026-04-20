import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var bleManager: BLEManager
    @StateObject private var session = RunSession()
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // Connection status bar
                    HStack {
                        Circle()
                            .fill(bleManager.isConnected ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(bleManager.isConnected ? "Connected to GaitTracker" : "Disconnected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        // Battery
                        Label("\(bleManager.metrics.batteryLevel)%", systemImage: batteryIcon)
                            .font(.caption)
                            .foregroundColor(bleManager.metrics.batteryLevel < 20 ? .red : .secondary)
                    }
                    .padding(.horizontal)

                    // Cadence - primary metric
                    MetricCard(
                        title: "Cadence",
                        value: "\(session.isActive ? session.metrics.cadence : bleManager.metrics.cadence)",
                        unit: "steps/min",
                        color: cadenceColor,
                        icon: "metronome"
                    )

                    // Stride length and foot strike side by side
                    HStack(spacing: 16) {
                        SmallMetricCard(
                            title: "Stride",
                            value: String(format: "%.2f", session.isActive ? session.metrics.strideLength : bleManager.metrics.strideLength),
                            unit: "m",
                            color: .blue,
                            icon: "ruler"
                        )

                        StrikeCard(strikeType: session.isActive ? session.metrics.strikeType : bleManager.metrics.strikeType)
                    }

                    // Distance and duration
                    HStack(spacing: 16) {
                        SmallMetricCard(
                            title: "Distance",
                            value: session.isActive ? session.metrics.distanceFormatted : "0 m",
                            unit: "",
                            color: .purple,
                            icon: "map"
                        )

                        SmallMetricCard(
                            title: "Time",
                            value: session.isActive ? session.metrics.durationFormatted : "00:00",
                            unit: "",
                            color: .orange,
                            icon: "timer"
                        )
                    }

                    // Pace
                    if session.isActive {
                        MetricCard(
                            title: "Pace",
                            value: session.metrics.paceFormatted,
                            unit: "",
                            color: .teal,
                            icon: "speedometer"
                        )
                    }

                    // Run control buttons
                    RunControlButtons(session: session)
                        .padding(.top, 8)
                }
                .padding()
            }
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

    private var batteryIcon: String {
        let level = bleManager.metrics.batteryLevel
        if level > 75 { return "battery.100" }
        if level > 50 { return "battery.75" }
        if level > 25 { return "battery.50" }
        if level > 10 { return "battery.25" }
        return "battery.0"
    }
}

// MARK: - Run Control Buttons
struct RunControlButtons: View {
    @ObservedObject var session: RunSession
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        HStack(spacing: 16) {
            if !session.isActive {
                Button(action: { session.start() }) {
                    Label("Start Run", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .fontWeight(.semibold)
                }
            } else {
                if session.isPaused {
                    Button(action: { session.resume() }) {
                        Label("Resume", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .fontWeight(.semibold)
                    }
                } else {
                    Button(action: { session.pause() }) {
                        Label("Pause", systemImage: "pause.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .fontWeight(.semibold)
                    }
                }

                Button(action: {
                    if let record = session.stop() {
                        dataManager.save(record)
                    }
                }) {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Metric Cards
struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct SmallMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct StrikeCard: View {
    let strikeType: StrikeType

    private var color: Color {
        switch strikeType {
        case .heel:     return .red
        case .midfoot:  return .yellow
        case .forefoot: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Strike", systemImage: "shoe")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(strikeType.description)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(strikeType.advice)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
