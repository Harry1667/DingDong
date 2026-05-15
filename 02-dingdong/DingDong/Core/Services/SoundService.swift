import Foundation
import AVFoundation

/// 對齊網頁 /simple 的 WebAudio 音效：tap / back / ding / dingdong / send。
/// 每次播放都建立獨立的 AVAudioEngine，先 attach / connect 再 start，
/// 避免 AVAudioEngineGraph::Initialize 在 graph 空狀態下丟 NSException。
@MainActor
final class SoundService {
    static let shared = SoundService()
    private init() {}

    private let sampleRate: Double = 44_100

    var isEnabled: Bool {
        get { (UserDefaults.standard.object(forKey: "dd_sound") as? Bool) ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "dd_sound") }
    }

    // MARK: - Public

    func tap()      { play([Tone(freq: 1800, duration: 0.04, vol: 0.10, type: .square)]) }
    func back()     { play([
        Tone(freq: 420, duration: 0.10, vol: 0.16, type: .triangle),
        Tone(freq: 280, duration: 0.12, vol: 0.14, type: .triangle, delay: 0.05),
    ]) }
    func send()     { play([Tone(freq: 880, duration: 0.08, vol: 0.14, type: .sine)]) }
    func ding()     { play([Tone(freq: 1320, duration: 0.25, vol: 0.20, type: .triangle)]) }
    func dingDong() { play([
        Tone(freq: 1320, duration: 0.22, vol: 0.22, type: .triangle),
        Tone(freq: 990,  duration: 0.32, vol: 0.22, type: .triangle, delay: 0.18),
    ]) }

    // MARK: - Internal

    private struct Tone {
        let freq: Double
        let duration: Double
        let vol: Float
        let type: WaveType
        var delay: Double = 0
    }
    private enum WaveType { case sine, triangle, square }

    private func play(_ tones: [Tone]) {
        guard isEnabled, !tones.isEmpty else { return }
        configureSessionIfNeeded()

        let engine = AVAudioEngine()
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        else { return }

        // 先觸發 mainMixerNode（lazy 會自動連到 outputNode），否則 start() 會炸
        let mixer = engine.mainMixerNode

        var players: [AVAudioPlayerNode] = []
        var buffers: [AVAudioPCMBuffer] = []
        for tone in tones {
            let player = AVAudioPlayerNode()
            engine.attach(player)
            engine.connect(player, to: mixer, format: format)
            players.append(player)
            buffers.append(buildBuffer(tone: tone, format: format))
        }

        do {
            try engine.start()
        } catch {
            return
        }

        var maxEnd: Double = 0
        for (idx, tone) in tones.enumerated() {
            let player = players[idx]
            let buffer = buffers[idx]
            maxEnd = max(maxEnd, tone.delay + tone.duration)
            DispatchQueue.main.asyncAfter(deadline: .now() + tone.delay) {
                player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
                player.play()
            }
        }

        // 播完後關掉 engine 釋放資源
        let total = maxEnd + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + total) {
            engine.stop()
        }
    }

    private func buildBuffer(tone: Tone, format: AVAudioFormat) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(max(1.0, tone.duration * sampleRate))
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let ptr = buffer.floatChannelData![0]
        let twoPi = 2 * Double.pi
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let theta = twoPi * tone.freq * t
            let raw: Float
            switch tone.type {
            case .sine:     raw = Float(sin(theta))
            case .triangle: raw = Float(2.0 / Double.pi * asin(sin(theta)))
            case .square:   raw = sin(theta) >= 0 ? 1.0 : -1.0
            }
            let attack = min(t / 0.005, 1.0)
            let decay  = exp(-t / max(tone.duration * 0.4, 0.05))
            ptr[i] = raw * tone.vol * Float(attack * decay)
        }
        return buffer
    }

    private var sessionConfigured = false
    private func configureSessionIfNeeded() {
        guard !sessionConfigured else { return }
        sessionConfigured = true
        #if canImport(UIKit)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true, options: [])
        #endif
    }
}
