import Foundation

/// Canvas & Media Capture Spoofing Panel (Roadmap Item 68)
/// Provide custom dummy video or audio feeds when a website requests webcam
/// or microphone access.
final class MediaCaptureSpoofer {
    static let shared = MediaCaptureSpoofer()

    @Published var isEnabled = false
    @Published var selectedDummyVideo = "black"
    @Published var selectedDummyAudio = "silence"

    private init() {}

    func spoofingScript() -> String {
        guard isEnabled else { return "" }
        return """
        (function() {
            if (window.__soulMediaSpoofed) return;
            window.__soulMediaSpoofed = true;

            const origGetUserMedia = navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);
            navigator.mediaDevices.getUserMedia = function(constraints) {
                if (constraints.video) {
                    return Promise.resolve(createDummyVideoStream());
                }
                if (constraints.audio) {
                    return Promise.resolve(createDummyAudioStream());
                }
                return origGetUserMedia(constraints);
            };

            function createDummyVideoStream() {
                const canvas = document.createElement('canvas');
                canvas.width = 640;
                canvas.height = 480;
                const ctx = canvas.getContext('2d');
                ctx.fillStyle = '#000';
                ctx.fillRect(0, 0, 640, 480);
                ctx.fillStyle = '#fff';
                ctx.font = '20px sans-serif';
                ctx.fillText('Soul Spoofed Camera', 220, 240);
                return canvas.captureStream(30);
            }

            function createDummyAudioStream() {
                const ctx = new AudioContext();
                const dest = ctx.createMediaStreamDestination();
                return dest.stream;
            }
        })();
        """
    }
}
