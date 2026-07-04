import AVFoundation

@MainActor
final class TonePlayer {

    static let shared = TonePlayer()

    private var player: AVAudioPlayer?

    private init() {}

    /// Plays the given tone's source audio once, in-app, so the user can preview it while picking a reminder sound.
    func preview(_ tone: ReminderTone) {
        player?.stop()
        player = nil

        guard let fileName = tone.soundFileName else { return }
        let baseName = (fileName as NSString).deletingPathExtension
        guard let url = Bundle.main.url(forResource: baseName, withExtension: "mp3") else { return }

        let newPlayer = try? AVAudioPlayer(contentsOf: url)
        newPlayer?.numberOfLoops = 0
        newPlayer?.play()
        player = newPlayer
    }
}
