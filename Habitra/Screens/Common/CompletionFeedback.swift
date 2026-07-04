import AVFoundation
import UIKit

enum CompletionFeedback {

    private static var player: AVAudioPlayer?
    private static let generator = UIImpactFeedbackGenerator(style: .medium)

    static func playComplete() {
        generator.impactOccurred()
        play(named: "complete")
    }

    static func playRemove() {
        generator.impactOccurred()
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
