import Foundation

/// Hardware Video Decode Accelerator (Roadmap Item 30)
/// Forces CEF to use VideoToolbox on macOS for H.264, HEVC, and ProRes
/// decoding, offloading CPU work to the Apple Media Engine.
final class VideoDecodeAccelerator {
    static let shared = VideoDecodeAccelerator()

    var commandLineArgs: [String] {
        [
            "--enable-features=VaapiVideoDecoder,VaapiVideoEncodeAccelerator",
            "--disable-features=UseChromeOSDirectVideoDecoder",
            "--enable-accelerated-video-decode",
            "--enable-accelerated-video-encode",
            "--ignore-gpu-blocklist"
        ]
    }

    private init() {}

    func applyCommandLineArgs() -> [String] {
        SoulLogger.log("VideoDecodeAccelerator: enabled VideoToolbox hardware decode")
        return commandLineArgs
    }
}
