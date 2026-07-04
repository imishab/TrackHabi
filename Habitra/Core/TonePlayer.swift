import AVFoundation

@MainActor
final class TonePlayer {

    static let shared = TonePlayer()

    private var player: AVAudioPlayer?

    private init() {}

    /// Plays the given tone's source audio in-app so the user can preview it while picking a reminder sound.
    func preview(_ tone: ReminderTone) {
        guard let fileName = tone.soundFileName else { return }
        let baseName = (fileName as NSString).deletingPathExtension
        guard let url = Bundle.main.url(forResource: baseName, withExtension: "mp3") else { return }

        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
