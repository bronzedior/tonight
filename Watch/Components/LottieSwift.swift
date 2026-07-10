//
//  LottieSwift.swift
//  tonight
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 10/07/26.
//

import SwiftUI
import SDWebImage
import SDWebImageLottieCoder
import Combine

final class LottieViewModel: ObservableObject {
    @Published private(set) var image: UIImage = UIImage()

    var frames: [UIImage] = []
    var durations: [TimeInterval] = []
    var currentIndex = 0
    var timer: Timer?

    init() {
        SDImageCodersManager.shared.addCoder(SDImageLottieCoder.shared)
    }

    func loadAnimation(named filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let animated = SDAnimatedImage(data: data) else { return }

        let count = animated.animatedImageFrameCount
        frames = (0..<count).compactMap { animated.animatedImageFrame(at: $0) }
        durations = (0..<count).map { animated.animatedImageDuration(at: $0) }

        currentIndex = 0
        if let first = frames.first { image = first }
        playNextFrame()
    }

    func playNextFrame() {
        guard !frames.isEmpty else { return }
        let delay = durations[currentIndex]
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.currentIndex = (self.currentIndex + 1) % self.frames.count
            self.image = self.frames[self.currentIndex]
            self.playNextFrame()
        }
    }

    deinit { timer?.invalidate() }
}

struct LottieAnimationView: View {
    @StateObject var viewModel = LottieViewModel()
    let fileName: String

    var body: some View {
        Image(uiImage: viewModel.image)
            .resizable()
            .scaledToFit()
            .onAppear {
                viewModel.loadAnimation(named: fileName)
            }
    }
}
