import CoreBluetooth
import Combine

// UUIDs must match Arduino firmware exactly
private let gaitServiceUUID        = CBUUID(string: "19b10000-e8f2-537e-4f6c-d104768a1214")
private let strideLengthCharUUID   = CBUUID(string: "19b10001-e8f2-537e-4f6c-d104768a1214")
private let cadenceCharUUID        = CBUUID(string: "19b10002-e8f2-537e-4f6c-d104768a1214")
private let strikeTypeCharUUID     = CBUUID(string: "19b10003-e8f2-537e-4f6c-d104768a1214")
private let batteryCharUUID        = CBUUID(string: "00002a19-0000-1000-8000-00805f9b34fb")

class BLEManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var metrics = GaitMetrics()
    @Published var statusMessage = "Tap Scan to find your GaitTracker"

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?

    private var strideLengthChar: CBCharacteristic?
    private var cadenceChar: CBCharacteristic?
    private var strikeTypeChar: CBCharacteristic?
    private var batteryChar: CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            statusMessage = "Bluetooth is not available"
            return
        }
        discoveredDevices.removeAll()
        isScanning = true
        statusMessage = "Scanning for GaitTracker..."
        centralManager.scanForPeripherals(withServices: [gaitServiceUUID], options: nil)
    }

    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        statusMessage = discoveredDevices.isEmpty ? "No devices found. Try again." : "Select your device to connect"
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        isScanning = false
        statusMessage = "Connecting to \(peripheral.name ?? "device")..."
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect() {
        guard let peripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            statusMessage = "Tap Scan to find your GaitTracker"
        case .poweredOff:
            statusMessage = "Please turn on Bluetooth"
            isConnected = false
        case .unauthorized:
            statusMessage = "Bluetooth permission denied"
        default:
            statusMessage = "Bluetooth unavailable"
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([gaitServiceUUID])
        statusMessage = "Connected to \(peripheral.name ?? "GaitTracker")"
        isConnected = true
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        statusMessage = "Connection failed. Try again."
        isConnected = false
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        isConnected = false
        statusMessage = "Disconnected. Tap Scan to reconnect."
        strideLengthChar = nil
        cadenceChar = nil
        strikeTypeChar = nil
        batteryChar = nil
    }
}

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(
                [strideLengthCharUUID, cadenceCharUUID, strikeTypeCharUUID, batteryCharUUID],
                for: service
            )
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for char in characteristics {
            switch char.uuid {
            case strideLengthCharUUID:
                strideLengthChar = char
                peripheral.setNotifyValue(true, for: char)
            case cadenceCharUUID:
                cadenceChar = char
                peripheral.setNotifyValue(true, for: char)
            case strikeTypeCharUUID:
                strikeTypeChar = char
                peripheral.setNotifyValue(true, for: char)
            case batteryCharUUID:
                batteryChar = char
                peripheral.setNotifyValue(true, for: char)
            default:
                break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let data = characteristic.value else { return }

        switch characteristic.uuid {
        case strideLengthCharUUID:
            let value = data.withUnsafeBytes { $0.load(as: Float.self) }
            metrics.strideLength = value
            metrics.distance += value
            metrics.stepCount += 1

        case cadenceCharUUID:
            let value = data.withUnsafeBytes { $0.load(as: UInt16.self) }
            metrics.cadence = Int(value)

        case strikeTypeCharUUID:
            let value = data.withUnsafeBytes { $0.load(as: UInt8.self) }
            metrics.strikeType = StrikeType(rawValue: value) ?? .midfoot

        case batteryCharUUID:
            let value = data.withUnsafeBytes { $0.load(as: UInt8.self) }
            metrics.batteryLevel = Int(value)

        default:
            break
        }
    }
}
