//
//  KaraokeViewController.swift
//  hackathon
//
//  Created by Daniel Jones on 12/10/22.
//

import UIKit

class KaraokeViewController: UIViewController {
    private let karoakeView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func setKaroakeView() {
        karoakeView = UIView()
        self.view.addSubview(karoakeView)
    }

}
