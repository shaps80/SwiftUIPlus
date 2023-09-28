import SwiftUI
import AVFoundation

private enum PlayerError: LocalizedError {
    case badUrl(Audio)
    var errorDescription: String? {
        switch self {
        case let .badUrl(audio):
            return "Couldn't play sound: \(audio.url.lastPathComponent), the URL was invalid."
        }
    }
}

internal final class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    
    @MainActor
    func play(audio: Audio) async throws {
#if os(iOS)
        await stop()

        try AVAudioSession.sharedInstance().setCategory(.ambient)
        try AVAudioSession.sharedInstance().setActive(true)
#endif

        player = try AVAudioPlayer(contentsOf: audio.url)
        player?.delegate = self
        player?.play()
    }
    
    @MainActor
    func stop() async {
        player?.stop()
        player = nil
    }

    @MainActor
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { await stop() }
    }
}
