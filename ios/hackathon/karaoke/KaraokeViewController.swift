//
//  KaraokeViewController.swift
//  hackathon
//
//  Created by Daniel Jones on 12/10/22.
//

import UIKit
import SnapKit
import AVFoundation

struct KWord {
    let timestamp: Double
    let word: String
}

class KaraokeViewController: UIViewController {
    private let karoakeView = UIStackView()
    private var lines: [String] = []
    private var kWords: [KWord] = []
    private var timer: Timer?
    private var player: AVAudioPlayer?
    
    override func loadView() {
        super.loadView()
        setGradientBackground()
        setKaroakeView()
        setNavBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func setNavBar() {
        let searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchPressed))
        navigationItem.leftBarButtonItem = searchBtn
    }
    
    private func setTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { timer in
            self.highlightWord()
        })
    }
    
    private func highlightWord() {
        for (index, word) in kWords.enumerated() {
            if kWords.indices.contains(index + 1) {
                let nextTime = kWords[index + 1].timestamp
                let currentTime = player?.currentTime ?? 0.0
                if currentTime >= word.timestamp && currentTime <= nextTime {
                    for lineView in karoakeView.arrangedSubviews {
                        if let lineView = lineView as? UILabel, let text = lineView.text, text.contains(word.word) {
                            let range = (text as NSString).range(of: word.word)

                            let attributedText = NSMutableAttributedString.init(string: text)
                            let blue = UIColor.init(red: 48 / 255.0, green: 196 / 255.0, blue: 246 / 255.0, alpha: 1.0)
                            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: blue , range: range)
                            lineView.attributedText = attributedText
                        }
                    }
                    
                }
            }
        }
    }
    
    private func findLine(with word: String) -> Int? {
        let index = lines.firstIndex { line in
            return line.contains(word)
        }
        
        return index
    }
    
    @objc private func searchPressed() {
        player?.pause()
        let searchVC = SearchViewController()
        searchVC.receivedYoutubeLink = { youtubeLink in
            print(youtubeLink)
        }
        self.navigationController?.pushViewController(searchVC, animated: true)
//        removeLine()
    }
    
    private func loadData() {
        lines = ["It's a little bit funny, this feeling inside",
                 "I'm not one of those who can easily hide",
                 "I don't have much money, but, boy, if I did",
                 "I'd buy a big house where we both could live"
        ]
        
        let word = KWord(timestamp: 1.02, word: "It's")
        kWords = [word, word, word, word]
        
        showLines()
        playSound()
        setTimer()
    }
    
    private func showLines() {
        for (index, line) in lines.enumerated() {
            if index < 5 {
                let color: UIColor = index == 0 ? .white : UIColor.white.withAlphaComponent(0.3)
                addLineToStackView(line: line, color: color)
            }
        }
    }
    
    private func removeLine() {
        lines.remove(at: 0)
        for subview in karoakeView.arrangedSubviews {
            karoakeView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        showLines()
    }
    
    private func setKaroakeView() {
        karoakeView.axis = .vertical
        karoakeView.distribution = .fill
        karoakeView.spacing = 10
        karoakeView.alignment = .leading
        view.addSubview(karoakeView)
        karoakeView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottomMargin.equalToSuperview()
            make.height.equalTo(250)
        }
    }
    
    private func addLineToStackView(line: String, color: UIColor) {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 33, weight: .bold)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.textColor = color
        label.text = line
        label.numberOfLines = 2
        label.sizeToFit()
        karoakeView.addArrangedSubview(label)
    }
    
    private func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        let color1 = Helpers.hexStringToUIColor(hex: "FF0072")
        let color2 = Helpers.hexStringToUIColor(hex: "FF7F47")
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = self.view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "john", withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

struct Helpers {
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
