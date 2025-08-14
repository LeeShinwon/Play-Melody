//
//  AudioManager.swift
//  Melody Practice
//
//  Created by 이신원 on 8/7/25.
//

import Foundation
import AVFoundation

class AudioManager {
    
    init() { }

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var currentKey: String?

    func play(note: String) {
        guard note != currentKey else { return } // 중복 재생 방지
        stopCurrent()

        guard let url = Bundle.main.url(forResource: note, withExtension: "mp3") else {
            print("⚠️ Missing audio file: \(note).mp3")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0
            player.play()
            currentKey = note
            audioPlayers[note] = player
            fadeIn(player: player)
        } catch {
            print("❌ Audio error: \(error)")
        }
    }

    func stopCurrent() {
        guard let key = currentKey, let player = audioPlayers[key] else { return }
        fadeOutAndStop(player: player)
        currentKey = nil
    }

    private func fadeIn(player: AVAudioPlayer) {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            player.volume += 0.1
            if player.volume >= 1.0 {
                player.volume = 1.0
                timer.invalidate()
            }
        }
    }

    private func fadeOutAndStop(player: AVAudioPlayer) {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            player.volume -= 0.1
            if player.volume <= 0 {
                player.volume = 0
                player.stop()
                timer.invalidate()
            }
        }
    }
}
