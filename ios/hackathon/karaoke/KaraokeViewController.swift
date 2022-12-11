//
//  KaraokeViewController.swift
//  hackathon
//
//  Created by Daniel Jones on 12/10/22.
//

import UIKit
import SnapKit

class KaraokeViewController: UIViewController {
    private let karoakeView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        setKaroakeView()
    }
    
    private func setKaroakeView() {
        karoakeView.axis = .vertical
        karoakeView.distribution = .fillProportionally
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
        label.textColor = color
        label.numberOfLines = 0
        karoakeView.addArrangedSubview(label)
    }
    
    private func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        let color1 = hexStringToUIColor(hex: "FF0072")
        let color2 = hexStringToUIColor(hex: "FF7F47")
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = self.view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
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
