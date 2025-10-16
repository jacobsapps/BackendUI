import SwiftUI
import AVFoundation

struct VoiceNoteInputView: View {
    @EnvironmentObject private var store: FormStore
    @StateObject private var recorder = AudioRecordingService()
    @State private var player: AVAudioPlayer?
    @State private var timer: Timer?
    @State private var levels: [CGFloat] = []
    @State private var playbackProgress: CGFloat = 0
    @State private var isPlaying = false
    let label: String
    let key: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label).font(.subheadline).padding(.top, 12)
            EqualizerView(levels: levels, playbackProgress: isPlaying ? playbackProgress : nil)
                .frame(height: 40)
            HStack(spacing: 12) {
                Button(recorder.isRecording ? "Stop" : "Record") { toggleRecord() }
                    .buttonStyle(.borderedProminent)
                Button(isPlaying ? "Pause" : "Play") { togglePlay() }
                    .buttonStyle(.bordered)
                    .disabled(!(hasVoiceData))
                if hasVoiceData { Text("Saved").foregroundStyle(.secondary) }
                Spacer()
            }
        }
        .padding(.vertical, 6)
        .onDisappear { stopTimersAndAudio() }
    }

    private var hasVoiceData: Bool {
        if case .voice = store.values[key] { return true }
        return false
    }

    private func toggleRecord() {
        Task {
            if recorder.isRecording {
                if let data = recorder.stop() { store.set(key, value: .voice(data)) }
                timer?.invalidate(); timer = nil
            } else {
                store.values[key] = nil
                player?.stop(); isPlaying = false
                levels.removeAll()
                timer?.invalidate(); timer = nil
                let granted = await recorder.requestPermission()
                if granted {
                    try? recorder.start()
                    startMeteringTimer()
                }
            }
        }
    }

    private func togglePlay() {
        guard case let .voice(data)? = store.values[key] else { return }
        if isPlaying {
            player?.pause(); isPlaying = false; timer?.invalidate(); timer = nil
        } else {
            do {
                player = try AVAudioPlayer(data: data)
                player?.isMeteringEnabled = true
                player?.play()
                isPlaying = true
                startPlaybackTimer()
            } catch { }
        }
    }

    private func startMeteringTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let power = recorder.currentAveragePower()
            let level = normalized(power: power)
            levels.append(level)
            if levels.count > 200 { levels.removeFirst(levels.count - 200) }
        }
    }

    private func startPlaybackTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            player?.updateMeters()
            let power = player?.averagePower(forChannel: 0) ?? -60
            let level = normalized(power: power)
            levels.append(level)
            if levels.count > 200 { levels.removeFirst(levels.count - 200) }
            if let p = player {
                playbackProgress = CGFloat(p.duration == 0 ? 0 : (p.currentTime / p.duration))
            }
            if player?.isPlaying == false { isPlaying = false; timer?.invalidate(); timer = nil; playbackProgress = 0 }
        }
    }

    private func stopTimersAndAudio() {
        timer?.invalidate(); timer = nil
        player?.stop(); isPlaying = false
    }

    private func normalized(power: Float) -> CGFloat {
        let minDb: Float = -60
        let clamped = max(minDb, power)
        let ratio = (clamped - minDb) / (-minDb)
        return CGFloat(ratio)
    }
}
