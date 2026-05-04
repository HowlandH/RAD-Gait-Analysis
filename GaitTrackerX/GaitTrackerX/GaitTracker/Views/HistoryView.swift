import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager

    // Charts use chronological order (oldest first), last 7 runs
    private var chartData: [RunRecord] {
        Array(dataManager.runHistory.reversed().suffix(7))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.init(white: 0.96, alpha: 1)).ignoresSafeArea()

                Group {
                    if dataManager.runHistory.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "figure.run.circle")
                                .font(.system(size: 64))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("No runs yet")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Complete a run to see your history here")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {

                                // Charts section — only show if 2+ runs
                                if dataManager.runHistory.count >= 2 {
                                    CadenceChartCard(data: chartData)
                                    DistanceChartCard(data: chartData)
                                    StrikeDistributionCard(history: dataManager.runHistory)
                                }

                                // Section header
                                HStack {
                                    Text("All Runs")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(dataManager.runHistory.count) total")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 4)
                                .padding(.top, 4)

                                ForEach(dataManager.runHistory) { run in
                                    NavigationLink(destination: RunDetailView(run: run)) {
                                        RunHistoryCard(run: run)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    if !dataManager.runHistory.isEmpty {
                        ShareLink(
                            item: dataManager.exportCSV(),
                            subject: Text("GaitTracker Run History"),
                            message: Text("Exported from GaitTracker")
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Cadence Chart
// Uses array index as X value so same-day runs never collide

struct CadenceChartCard: View {
    let data: [RunRecord]

    private func cadenceColor(_ cadence: Int) -> Color {
        if cadence < 160 { return .red }
        if cadence < 170 { return .orange }
        if cadence <= 180 { return .green }
        return .blue
    }

    var body: some View {
        ChartCard(title: "Cadence Trend", subtitle: "Last \(data.count) runs", icon: "metronome.fill", color: .purple) {
            Chart(Array(data.enumerated()), id: \.element.id) { idx, run in
                BarMark(
                    x: .value("Run", idx),
                    y: .value("Cadence", run.averageCadence)
                )
                .foregroundStyle(cadenceColor(run.averageCadence))
                .cornerRadius(6)

                RuleMark(y: .value("Optimal", 170))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(.green.opacity(0.5))
                    .annotation(position: .trailing) {
                        Text("170")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
            }
            .chartYScale(domain: 0...220)
            .chartYAxis {
                AxisMarks(values: [0, 60, 120, 150, 160, 170, 180, 200]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Int.self), [0, 150, 170, 200].contains(v) {
                            Text("\(v)")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: Array(0..<data.count)) { value in
                    AxisValueLabel {
                        if let i = value.as(Int.self), i < data.count {
                            Text(shortDate(data[i].date))
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 160)
        }
    }
}

// MARK: - Distance Chart

struct DistanceChartCard: View {
    let data: [RunRecord]

    var body: some View {
        ChartCard(title: "Distance per Run", subtitle: "Last \(data.count) runs", icon: "map.fill", color: .blue) {
            Chart(Array(data.enumerated()), id: \.element.id) { idx, run in
                BarMark(
                    x: .value("Run", idx),
                    y: .value("Distance", Double(run.distance))
                )
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .blue.opacity(0.6)],
                                   startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(v >= 1000 ? String(format: "%.1fk", v / 1000) : String(format: "%.0f", v))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: Array(0..<data.count)) { value in
                    AxisValueLabel {
                        if let i = value.as(Int.self), i < data.count {
                            Text(shortDate(data[i].date))
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 160)
        }
    }
}

// MARK: - Strike Distribution Chart

struct StrikeDistributionCard: View {
    let history: [RunRecord]

    private var strikeCounts: [(type: String, count: Int, color: Color)] {
        let heel     = history.filter { $0.strikeType == .heel }.count
        let midfoot  = history.filter { $0.strikeType == .midfoot }.count
        let forefoot = history.filter { $0.strikeType == .forefoot }.count
        return [
            ("Heel",     heel,     .red),
            ("Midfoot",  midfoot,  .green),
            ("Forefoot", forefoot, .blue)
        ].filter { $0.count > 0 }
    }

    var body: some View {
        ChartCard(title: "Strike Distribution", subtitle: "\(history.count) runs total", icon: "shoe.fill", color: .indigo) {
            HStack(spacing: 20) {
                Chart(strikeCounts, id: \.type) { item in
                    SectorMark(
                        angle: .value("Runs", item.count),
                        innerRadius: .ratio(0.55),
                        angularInset: 2
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(4)
                }
                .frame(width: 120, height: 120)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(strikeCounts, id: \.type) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 10, height: 10)
                            Text(item.type)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(item.count)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(item.color)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Shared Chart Card Container

struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            content
        }
        .padding(16)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Run History Card

struct RunHistoryCard: View {
    let run: RunRecord

    private var strikeColor: Color {
        switch run.strikeType {
        case .heel:     return .red
        case .midfoot:  return .green
        case .forefoot: return .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(run.dateFormatted)
                        .font(.headline)
                    Text("\(run.stepCount) steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(strikeColor)
                        .frame(width: 8, height: 8)
                    Text(run.strikeType.description)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(strikeColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(strikeColor.opacity(0.12))
                .clipShape(Capsule())

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }

            Divider()

            HStack {
                RunStat(label: "Distance", value: run.distanceFormatted, icon: "map.fill", color: .blue)
                Spacer()
                RunStat(label: "Duration", value: run.durationFormatted, icon: "timer", color: .indigo)
                Spacer()
                RunStat(label: "Cadence", value: "\(run.averageCadence)", unit: "spm", icon: "metronome.fill", color: .purple)
                Spacer()
                RunStat(label: "Stride", value: String(format: "%.2f", run.averageStrideLength), unit: "m", icon: "ruler.fill", color: .teal)
            }
        }
        .padding(16)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Run Stat

struct RunStat: View {
    let label: String
    let value: String
    var unit: String = ""
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Helpers

private func shortDate(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "M/d"
    return f.string(from: date)
}
