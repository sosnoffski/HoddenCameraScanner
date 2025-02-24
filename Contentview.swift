import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var motionManager = MotionManager()
    @State private var result = "Нажми 'Старт' для сканирования"
    
    var body: some View {
        VStack {
            Text(result)
                .font(.title)
                .padding()
            Button("Старт") {
                cameraManager.startCamera()
                motionManager.startMotionTracking()
                result = "Сканирую комнату..."
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            Button("Стоп") {
                cameraManager.stopCamera()
                motionManager.stopMotionTracking()
                result = motionManager.isRoomScanned ? "Комната просканирована. Подозрительное: `\(cameraManager.detectionCount)" : "Сканирование не завершено"
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onReceive(cameraManager.$detectionCount) { count in
            if count > 0 {
                result = "Обнаружено подозрительное: `\(count)"
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
