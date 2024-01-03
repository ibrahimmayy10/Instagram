//
//  MessageTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 30.10.2023.
//

import UIKit
import AVKit
import AVFoundation

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var incomingMessageLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
            
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        messageLabel.numberOfLines = 0
        incomingMessageLabel.numberOfLines = 0

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithMessage(_ message: String, isIncoming: Bool, videoUrl: String?) {
        messageLabel.layer.cornerRadius = messageLabel.frame.size.height / 2
        messageLabel.clipsToBounds = true
        
        incomingMessageLabel.layer.cornerRadius = incomingMessageLabel.frame.size.height / 2
        incomingMessageLabel.clipsToBounds = true
 
        if isIncoming {
            incomingMessageLabel.text = message
            incomingMessageLabel.isHidden = false
            messageLabel.isHidden = true
            
        } else {
            messageLabel.text = message
            messageLabel.isHidden = false
            incomingMessageLabel.isHidden = true
        }
    }
    
}
