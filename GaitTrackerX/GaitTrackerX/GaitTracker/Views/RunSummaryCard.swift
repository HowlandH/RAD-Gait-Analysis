import SwiftUI
import ImageIO

// MARK: - Card View

struct RunSummaryCardView: View {
    let run: RunRecord

    static let cardWidth: CGFloat  = 390
    static let cardHeight: CGFloat = 680

    private var cadenceColor: Color {
        if run.averageCadence == 0  { return .gray }
        if run.averageCadence < 160 { return Color(red: 1.0, green: 0.3, blue: 0.3) }
        if run.averageCadence < 170 { return Color(red: 1.0, green: 0.7, blue: 0.2) }
        if run.averageCadence <= 180 { return Color(red: 0.2, green: 0.9, blue: 0.5) }
        return Color(red: 0.3, green: 0.7, blue: 1.0)
    }

    private var strikeColor: Color {
        switch run.strikeType {
        case .heel:     return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .midfoot:  return Color(red: 0.2, green: 0.9, blue: 0.5)
        case .forefoot: return Color(red: 0.3, green: 0.7, blue: 1.0)
        }
    }

    private var performanceMessage: String {
        if run.averageCadence == 0   { return "Keep going!" }
        if run.averageCadence < 160  { return "Work on increasing step rate" }
        if run.averageCadence < 170  { return "Getting closer to optimal form" }
        if run.averageCadence <= 180 { return "Optimal cadence — great form!" }
        return "High energy run!"
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.10, green: 0.03, blue: 0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Ambient glow behind distance number
            Circle()
                .fill(cadenceColor.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: 40, y: -60)

            VStack(spacing: 0) {

                // Header bar
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(cadenceColor)
                        Text("GAITTRACKER")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(2.5)
                    }
                    Spacer()
                    Text(run.dateFormatted)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                }
                .padding(.horizontal, 28)
                .padding(.top, 38)

                Spacer()

                // Hero metric — distance
                VStack(spacing: 4) {
                    Text("DISTANCE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                        .tracking(4)
                    Text(run.distanceFormatted)
                        .font(.system(size: 76, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }

                Spacer()

                // Divider
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.horizontal, 28)

                // Stats row
                HStack(spacing: 0) {
                    CardStatColumn(value: "\(run.averageCadence)", unit: "spm",   label: "CADENCE",  color: cadenceColor)
                    Rectangle().fill(.white.opacity(0.08)).frame(width: 1, height: 44)
                    CardStatColumn(value: "\(run.stepCount)",      unit: "steps", label: "STEPS",    color: .white)
                    Rectangle().fill(.white.opacity(0.08)).frame(width: 1, height: 44)
                    CardStatColumn(value: run.durationFormatted,   unit: "",      label: "DURATION", color: .white)
                }
                .padding(.vertical, 26)
                .padding(.horizontal, 16)

                // Divider
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.horizontal, 28)

                // Strike + message
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(strikeColor)
                            .frame(width: 7, height: 7)
                        Text("\(run.strikeType.description.uppercased()) STRIKE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(strikeColor)
                            .tracking(1.2)
                        Spacer()
                    }
                    Text(performanceMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.vertical, 22)

                // Footer
                Text("gaittracker.app")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.2))
                    .tracking(1.5)
                    .padding(.bottom, 30)
            }
        }
        .frame(width: RunSummaryCardView.cardWidth, height: RunSummaryCardView.cardHeight)
    }
}

// MARK: - Stat Column

struct CardStatColumn: View {
    let value: String
    let unit: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(color)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(color.opacity(0.65))
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white.opacity(0.3))
                .tracking(1.5)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Renderer

/// Renders `RunSummaryCardView` to a PNG file in the temp directory and returns its URL.
@MainActor
func renderRunSummaryCard(run: RunRecord) -> URL? {
    let card = RunSummaryCardView(run: run)
    let renderer = ImageRenderer(content: card)
    renderer.scale = 3.0

    guard let cgImage = renderer.cgImage else { return nil }

    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("GaitTracker_\(run.id.uuidString).png")

    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else { return nil }
    CGImageDestinationAddImage(dest, cgImage, nil)
    guard CGImageDestinationFinalize(dest) else { return nil }

    return url
}
