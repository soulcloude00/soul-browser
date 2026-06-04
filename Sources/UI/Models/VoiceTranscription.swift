import Foundation
import AVFoundation

/// Local AI Voice Control & Transcription (Roadmap Item 17)
/// Streams microphone input through Apple CoreAudio to a local, lightweight
/// Whisper model embedded inside the Soul Helper process.
/// On macOS, AVAudioSession is unavailable; we use AVAudioEngine directly.
final class VoiceTranscription: ObservableObject {
    static let shared = VoiceTranscription()

    @Published var isRecording = false
    @Published var transcript = ""
    @Published var errorMessage: String?

    private var audioEngine = AVAudioEngine()
    private let whisperEndpoint = "http://localhost:9000/transcribe"

    private init() {}

    func startRecording() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
        } catch {
            errorMessage = "Audio session setup failed: \(error)"
            return
        }
        #endif

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }

        do {
            try audioEngine.start()
            isRecording = true
            transcript = ""
        } catch {
            errorMessage = "Audio engine start failed: \(error)"
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isRecording = false
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // In production: buffer audio, periodically send to local Whisper endpoint.
        // Stub: logs buffer size.
        SoulLogger.log("VoiceTranscription: buffered \(buffer.frameLength) samples")
    }
}
