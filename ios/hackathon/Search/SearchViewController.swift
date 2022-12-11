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
    private var saveBtn = UIButton()
    
    var receivedYoutubeLink: ((String) -> ())?
    
    override func loadView() {
        super.loadView()
        setBtn()
        setWebView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string:"https://youtube.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)

    }
    
    private func setBtn() {
        saveBtn.setTitle("Select Song", for: .normal)
        saveBtn.setTitleColor(.black, for: .normal)
        saveBtn.addTarget(self, action: #selector(saveBtnPressed), for: .touchUpInside)
        saveBtn.layer.cornerRadius = 10
        let pink = Helpers.hexStringToUIColor(hex: "FF0072")
        saveBtn.backgroundColor = pink
        self.view.addSubview(saveBtn)
        saveBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(75)
            make.topMargin.equalToSuperview().offset(50)
        }
    }
    
    @objc private func saveBtnPressed() {
        if let url = webView.url {
            let urlStr = url.absoluteString
            receivedYoutubeLink?(urlStr)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(saveBtn.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
    }
}
