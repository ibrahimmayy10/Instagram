//
//  MessageReelsTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 8.12.2023.
//

import UIKit
import AVKit
import AVFoundation

class MessageReelsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var incomingReelsView: UIView!
    @IBOutlet weak var sendReelsView: UIView!
    
    var playerViewController: AVPlayerViewController?
    var isIncomingReels: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    func configureWithReels(_ videoUrl: String, isIncoming: Bool) {
        self.isIncomingReels = isIncoming
                
        if playerViewController == nil {
            playerViewController = AVPlayerViewController()
        }
                
        guard let playerViewController = playerViewController else { return }
                
        let videoUrl = URL(string: videoUrl)
        let player = AVPlayer(url: videoUrl!)
        playerViewController.player = player
        
        if isIncoming {
            playerViewController.view.frame = incomingReelsView.bounds
            incomingReelsView.addSubview(playerViewController.view)
            incomingReelsView.isHidden = false
            sendReelsView.isHidden = true
        } else {
            playerViewController.view.frame = sendReelsView.bounds
            sendReelsView.addSubview(playerViewController.view)
            sendReelsView.isHidden = false
            incomingReelsView.isHidden = true
        }
    }
        
}
