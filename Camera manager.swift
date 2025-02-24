import AVFoundation
import Vision

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var detectionCount = 0
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var isRunning = false
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
        } catch {
            print("Ошибка настройки камеры: `\(error)")
        }
    }
    
    func startCamera() {
        if !isRunning {
            captureSession.startRunning()
            isRunning = true
        }
    }
    
    func stopCamera() {
        if isRunning {
            captureSession.stopRunning()
            isRunning = false
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectRectanglesRequest { request, error in
            if let results = request.results as? [VNRectangleObservation] {
                DispatchQueue.main.async {
                    self.detectionCount += results.count
                }
            }
        }
        request.minimumSize = 0.01
        request.maximumObservations = 10
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Ошибка анализа: `\(error)")
        }
    }
}
