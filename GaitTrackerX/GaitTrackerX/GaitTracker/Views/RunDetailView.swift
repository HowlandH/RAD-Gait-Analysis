import SwiftUI
import Charts

struct RunDetailView: View {
    let run: RunRecord
    @State private var shareURL: URL?

    private var cadenceColor: Color {
        if run.averageCadence == 0 { return .gray }
        if run.averageCadence < 160 { return .red }
        if run.averageCadence < 170 { return .orange }
        if run.averageCadence <= 180 { return .green }
        return .blue
    }

    private var paceString: String? {
        guard run.duration > 60, run.distance > 10 else { return nil }
        let paceSeconds = run.duration / Double(run.distance / 1000)
        let min = Int(paceSeconds) / 60
        let sec = Int(paceSeconds) % 60
        return String(format: "%d:%02d /km", min, sec)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Date / step count header
                VStack(spacing: 4) {
                    Text(run.dateFormatted)
                        .font(.headline)
                    Text("\(run.stepCount) steps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(.background)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)

                // Metric grid
                HStack(spacing: 14) {
                    DetailMetricCard(label: "Distance", value: run.distanceFormatted, icon: "map.fill", color: .blue)
                    DetailMetricCard(label: "Duration", value: run.durationFormatted, icon: "timer", color: .indigo)
                }
                HStack(spacing: 14) {
                    DetailMetricCard(label: "Cadence", value: "\(run.averageCadence)", unit: "spm", icon: "metronome.fill", color: cadenceColor)
                    DetailMetricCard(label: "Avg Stride", value: String(format: "%.2f", run.averageStrideLength), unit: "m", icon: "ruler.fill", color: .teal)
                }

                if let pace = paceString {
                    DetailMetricCard(label: "Average Pace", value: pace, icon: "speedometer", color: .orange)
                        .frame(maxWidth: .infinity)
                }

                // Strike distribution
                StrikeDetailCard(run: run)

                // Cadence performance guide
                CadenceGuideCard(cadence: run.averageCadence, color: cadenceColor)
            }
            .padding()
        }
        .background(Color(.init(white: 0.96, alpha: 1)).ignoresSafeArea())
        .navigationTitle("Run Details")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if let url = shareURL {
                    ShareLink(
                        item: url,
                        preview: SharePreview("Run Summary", image: Image(systemName: "figure.run"))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                } else {
                    ProgressView().scaleEffect(0.7)
                }
            }
        }
        .onAppear {
            shareURL = renderRunSummaryCard(run: run)
        }
    }
}

// MARK: - Detail Metric Card

struct DetailMetricCard: View {
    let label: String
    let value: String
    var unit: String = ""
    let icon: String
    let color: Color

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
                Text(label)
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

// MARK: - Strike Detail Card

struct StrikeDetailCard: View {
    let run: RunRecord

    private struct StrikeEntry: Identifiable {
        let id = UUID()
        let type: String
        let count: Int
        let color: Color
    }

    private var entries: [StrikeEntry] {
        if run.hasStrikeData {
            return [
                StrikeEntry(type: "Heel",     count: run.heelStrikes,     color: .red),
                StrikeEntry(type: "Midfoot",  count: run.midfootStrikes,  color: .green),
                StrikeEntry(type: "Forefoot", count: run.forefootStrikes, color: .blue)
            ].filter { $0.count > 0 }
        }
        // Older records: show dominant type only
        let color: Color
        switch run.strikeType {
        case .heel:     color = .red
        case .midfoot:  color = .green
        case .forefoot: color = .blue
        }
        return [StrikeEntry(type: run.strikeType.description, count: 1, color: color)]
    }

    private var total: Int { entries.reduce(0) { $0 + $1.count } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "shoe.fill")
                    .font(.caption)
                    .foregroundColor(.indigo)
                    .frame(width: 28, height: 28)
                    .background(Color.indigo.opacity(0.15))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 1) {
                    Text("Strike Distribution")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(run.hasStrikeData ? "\(total) steps tracked" : "Dominant type only")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            if run.hasStrikeData {
                HStack(spacing: 20) {
                    // Donut chart
                    Chart(entries) { item in
                        SectorMark(
                            angle: .value("Steps", item.count),
                            innerRadius: .ratio(0.55),
                            angularInset: 2
                        )
                        .foregroundStyle(item.color)
                        .cornerRadius(4)
                    }
                    .frame(width: 130, height: 130)

                    // Legend with percentages
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(entries) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 10, height: 10)
                                Text(item.type)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text("\(item.count)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(item.color)
                                    Text(String(format: "%.0f%%", Double(item.count) / Double(total) * 100))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // Fallback: dominant badge + advice
                let dominantEntry = entries[0]
                HStack(spacing: 8) {
                    Circle()
                        .fill(dominantEntry.color)
                        .frame(width: 12, height: 12)
                    Text("\(dominantEntry.type) Strike")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(dominantEntry.color)
                    Spacer()
                }
                Text(run.strikeType.advice)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Cadence Guide Card

struct CadenceGuideCard: View {
    let cadence: Int
    let color: Color

    private var message: String {
        if cadence == 0    { return "No cadence data recorded." }
        if cadence < 150   { return "Very low cadence. Aim for shorter, quicker steps." }
        if cadence < 160   { return "Below optimal. Try increasing step rate gradually." }
        if cadence < 170   { return "Getting there — most runners aim for 170-180 spm." }
        if cadence <= 180  { return "Optimal range. This cadence reduces injury risk and improves efficiency." }
        return "High cadence. Ensure you're not overstriding in the other direction."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "metronome.fill")
                    .font(.caption)
                    .foregroundColor(.purple)
                    .frame(width: 28, height: 28)
                    .background(Color.purple.opacity(0.15))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 1) {
                    Text("Cadence Analysis")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(cadence) steps/min")
                        .font(.caption2)
                        .foregroundColor(color)
                        .fontWeight(.semibold)
                }
                Spacer()
            }

            // Bar showing position relative to 140–200 spm scale
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 8)

                    // Optimal zone highlight (170–180)
                    let minScale: Double = 140
                    let maxScale: Double = 200
                    let optStart = (170 - minScale) / (maxScale - minScale)
                    let optWidth = (180 - 170) / (maxScale - minScale)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green.opacity(0.25))
                        .frame(width: geo.size.width * optWidth, height: 8)
                        .offset(x: geo.size.width * optStart)

                    // Current cadence marker
                    if cadence > 0 {
                        let pos = min(max((Double(cadence) - minScale) / (maxScale - minScale), 0), 1)
                        Circle()
                            .fill(color)
                            .frame(width: 14, height: 14)
                            .offset(x: geo.size.width * pos - 7, y: -3)
                    }
                }
            }
            .frame(height: 14)

            HStack {
                Text("140")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("170–180 optimal")
                    .font(.caption2)
                    .foregroundColor(.green)
                Spacer()
                Text("200")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}
