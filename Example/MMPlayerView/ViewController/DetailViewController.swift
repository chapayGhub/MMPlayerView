//
//  DetailViewController.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import MMPlayerView
class DetailViewController: UIViewController {
    var data: DataObj?
    fileprivate var playerLayer: MMPlayerLayer?
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var progress: UIProgressView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.mmPlayerTransition.present.pass { (config) in
            config.duration = 0.3
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        progress.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false        
        if let d = data {
            self.title = d.title
            textView.text = d.content
        }
        
        guard let downloadURL = self.data?.play_Url else {
            return
        }
        
        MMPlayerDownloader.shared.observe(downloadURL: downloadURL) { [weak self] (status) in
            switch status {
            case .cancelled:
                print("Download")
            case .completed:
                DispatchQueue.main.async {
                    self?.downloadBtn.setTitle("Delete", for: .normal)
                    self?.downloadBtn.isHidden = false
                    self?.progress.isHidden = true
                }
            case .downloading(let value):
                self?.downloadBtn.isHidden = true
                self?.progress.isHidden = false
                self?.progress.progress = value
                print("Exporting \(value) \(downloadURL)")
            case .failed(let err):
                DispatchQueue.main.async {
                    self?.downloadBtn.setTitle("Download", for: .normal)
                }
                
                self?.downloadBtn.isHidden = false
                self?.progress.isHidden = true
                print("Download Failed \(err)")
            case .none:
                DispatchQueue.main.async {
                    self?.downloadBtn.setTitle("Download", for: .normal)
                }
                self?.downloadBtn.isHidden = false
                self?.progress.isHidden = true
            case .exist:
                DispatchQueue.main.async {
                    self?.downloadBtn.setTitle("Delete", for: .normal)
                }
                self?.downloadBtn.isHidden = false
                self?.progress.isHidden = true
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func shrinkVideoAction() {
        (self.presentationController as? MMPlayerPassViewPresentatinController)?.shrinkView()
    }

    @IBAction func dismiss() {        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadAction() {
        
        guard let downloadURL = self.data?.play_Url else {
            return
        }
        if let info = MMPlayerDownloader.shared.localFileFrom(url: downloadURL)  {
            MMPlayerDownloader.shared.deleteVideo(info)
            let alert = UIAlertController(title: "Delete completed", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        DispatchQueue.main.async {
            MMPlayerDownloader.shared.download(url: downloadURL)
        }
    }
    deinit {
        print("Deinit")
    }
}

extension DetailViewController: MMPlayerToProtocol {
    
    func transitionCompleted(player: MMPlayerLayer) {
        self.playerLayer = player
    }

    var containerView: UIView {
        get {
            return playerContainer
        }
    }
}
