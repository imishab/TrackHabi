import AudioToolbox

enum CompletionFeedback {
    static func play() {
        AudioServicesPlaySystemSound(1025)
    }
}
