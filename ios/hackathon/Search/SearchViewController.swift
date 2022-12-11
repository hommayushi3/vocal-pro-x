//
//  SearchViewController.swift
//  hackathon
//
//  Created by Daniel Jones on 12/10/22.
//

import UIKit
import WebKit
import SnapKit

class SearchViewController: UIViewController {
    private var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        setWebView()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string:"https://youtube.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    private func setWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.topMargin.bottomMargin.leading.trailing.equalToSuperview()
        }
    }
}
