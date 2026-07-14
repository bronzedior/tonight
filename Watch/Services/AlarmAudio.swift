//
//  AlarmAudio.swift
//  tonight watch Watch App
//
//  Mainin suara alarm keras (looping) lewat speaker watch. Haptic sendiri nggak
//  bisa diatur volumenya, jadi buat "besarin suara" kita pakai AVAudioPlayer.
//

import Foundation
import AVFoundation

final class AlarmAudio {

    static let shared = AlarmAudio()

    private var player: AVAudioPlayer?

    private init() {}

    /// Mulai alarm: looping tanpa henti di volume maksimal.
    func start() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("[AlarmAudio] alarm.wav tidak ditemukan di bundle")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            // .playback = suara media (jalan walau ring/silent, dan pakai speaker).
            // .duckOthers = kalau ada audio lain, dikecilin biar alarm menonjol.
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1        // ulang terus sampai di-stop
            player.volume = 1.0              // maksimal (dibatasi volume sistem watch)
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            print("[AlarmAudio] gagal mulai: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
