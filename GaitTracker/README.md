# GaitTracker iOS App

iOS companion app for the running gait tracker device.

## Requirements

- Xcode 14.0+
- Swift 5.7+
- iOS 15.0+
- Physical iOS device (BLE doesn't work in Simulator)

## Project Structure

```
GaitTracker/
├── GaitTrackerApp.swift       # App entry point
├── Views/
│   ├── ConnectionView.swift   # BLE scanning/pairing
│   ├── DashboardView.swift    # Real-time metrics display
│   ├── HistoryView.swift      # Past runs
│   └── SettingsView.swift     # Configuration
├── Models/
│   ├── GaitMetrics.swift      # Data structures
│   └── RunSession.swift       # Run management
├── Managers/
│   ├── BLEManager.swift       # CoreBluetooth wrapper
│   └── DataManager.swift      # Persistence (Core Data)
└── Resources/
    └── Info.plist             # App configuration
```

## BLE Service Specification

### Service UUID
`19b10000-e8f2-537e-4f6c-d104768a1214`

### Characteristics

| Characteristic | UUID | Type | Properties | Description |
|---------------|------|------|-----------|-------------|
| Stride Length | `19b10001-...` | Float (4 bytes) | Read, Notify | Meters |
| Cadence | `19b10002-...` | Uint16 (2 bytes) | Read, Notify | Steps/min |
| Strike Type | `19b10003-...` | Uint8 (1 byte) | Read, Notify | 0=Heel, 1=Mid, 2=Forefoot |
| Battery Level | `00002a19-...` | Uint8 (1 byte) | Read, Notify | Percentage (0-100) |

## Setup Instructions

### 1. Create New Project
1. Open Xcode
2. Create new SwiftUI App project
3. Set minimum deployment target to iOS 15.0
4. Enable CoreBluetooth capability

### 2. Configure Info.plist
Add Bluetooth permissions:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to your GaitTracker device</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to communicate with your running tracker</string>
```

### 3. Implement BLEManager
```swift
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var currentMetrics = GaitMetrics()

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?

    // Service and Characteristic UUIDs
    let gaitServiceUUID = CBUUID(string: "19b10000-e8f2-537e-4f6c-d104768a1214")
    // ... add characteristic UUIDs
}
```

## Key Features

### Dashboard View
- Large cadence display (primary metric)
- Stride length with running average
- Color-coded foot strike indicator:
  - Red = Heel strike (higher impact)
  - Yellow = Midfoot strike (moderate)
  - Green = Forefoot strike (lower impact)
- Distance counter (stride × steps)
- Run timer
- Battery indicator

### Run History
- List of completed runs
- Summary statistics per run
- Charts showing metrics over time
- Tap to view detailed breakdown

### Settings
- **Leg Length Calibration** - Input for stride calculation
- **Units** - Toggle metric/imperial
- **Data Export** - Share runs as CSV

## Data Models

### GaitMetrics
```swift
struct GaitMetrics {
    var strideLength: Float = 0.0      // meters
    var cadence: Int = 0               // steps/min
    var strikeType: StrikeType = .mid
    var batteryLevel: Int = 100        // percentage
    var distance: Float = 0.0          // cumulative meters
    var duration: TimeInterval = 0     // seconds
}

enum StrikeType: UInt8 {
    case heel = 0
    case midfoot = 1
    case forefoot = 2
}
```

### RunSession
```swift
class RunSession: ObservableObject {
    @Published var isActive = false
    @Published var metrics = GaitMetrics()

    var startTime: Date?
    var stepCount: Int = 0

    func start() { }
    func pause() { }
    func stop() { }
    func save() { }
}
```

## Testing

### With nRF Connect App
Before building the full app, test BLE communication:
1. Download "nRF Connect" from App Store
2. Scan for "GaitTracker" device
3. Connect and view services
4. Subscribe to characteristics
5. Verify notifications update correctly

### With Physical Device
1. Build and run on iPhone
2. Power on Arduino device
3. Tap "Scan" in app
4. Connect to "GaitTracker"
5. Simulate foot strikes (tap device on desk)
6. Verify metrics update in real-time

## Development Tasks (Phase 5)

- [ ] Create SwiftUI project
- [ ] Implement BLEManager with CoreBluetooth
- [ ] Create GaitMetrics and RunSession models
- [ ] Build ConnectionView with device scanning
- [ ] Build DashboardView with real-time display
- [ ] Test connection and data parsing
- [ ] Handle disconnect/reconnect gracefully
- [ ] Add error handling and user feedback

## Future Enhancements (Phase 9)

- [ ] Implement HistoryView with Core Data
- [ ] Add SettingsView with calibration
- [ ] Create data visualization charts
- [ ] Implement CSV export
- [ ] Add haptic feedback on strikes
- [ ] Improve UI/UX polish

## Notes

- BLE requires physical iOS device (doesn't work in Simulator)
- Test with Arduino device powered on and advertising
- Connection may take 5-10 seconds initially
- Ensure UUIDs match between firmware and app
- Handle all BLE callbacks on main thread for UI updates
