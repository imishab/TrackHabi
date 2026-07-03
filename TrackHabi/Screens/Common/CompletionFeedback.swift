import AVFoundation

enum CompletionFeedback {

    private static var player: AVAudioPlayer?

    static func playComplete() {
        play(named: "complete")
    }

    static func playRemove() {
        play(named: "remove")
    }

    private static func play(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
            player = audioPlayer
        } catch {
            print("CompletionFeedback: failed to play \(name).mp3 – \(error)")
        }
    }
}
