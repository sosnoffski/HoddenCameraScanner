import CoreMotion

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private var totalRotation: Double = 0
    @Published var isRoomScanned = false
    
    func startMotionTracking() {
        totalRotation = 0
        isRoomScanned = false
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { (data, error) in
                if let rotation = data?.rotationRate {
                    let rotationDegrees = abs(rotation.z) * 180 / .pi
                    self.totalRotation += rotationDegrees * 0.1
                    if self.totalRotation >= 360 {
                        self.isRoomScanned = true
                        self.stopMotionTracking()
                    }
                }
            }
        }
    }
    
    func stopMotionTracking() {
        motionManager.stopGyroUpdates()
    }
}
