//
//  BannerAlert.swift
//  hackathon
//
//  Created by Daniel Jones on 12/11/22.
//

import Foundation
import BRYXBanner

class BannerAlert {
    enum BannerType {
        case success
        case error
        case info
    }
    
    static func show(title: String, subtitle: String, type: BannerType, duration: TimeInterval = 5) {
        var backgroundColor: UIColor = UIColor.red
        switch type {
        case .error:
            backgroundColor = UIColor.red
        case .success:
            backgroundColor = UIColor.systemGreen
        case .info:
            backgroundColor = .purple
        }
        
        let banner = Banner(title: title, subtitle: subtitle, backgroundColor: backgroundColor)
        banner.dismissesOnTap = true
        banner.show(duration: duration)
    }
    
    static func show(with error: Error?) {
        if let error = error {
            BannerAlert.show(title: "Error", subtitle: error.localizedDescription, type: .error)
        }
    }
    
    static func showUnknownError(functionName: String) {
        BannerAlert.show(title: "Error", subtitle: "There was an error using the \(functionName). Please contact the Ohana team at (317) 690 - 5323 to fix this.", type: .error)
    }
}
