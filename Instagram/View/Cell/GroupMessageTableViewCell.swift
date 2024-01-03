//
//  GroupMessageTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 3.11.2023.
//

import UIKit
import SDWebImage

class GroupMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
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
    
    func configureWithMessage(_ message: String, username: String, imageUrl: String, isIncoming: Bool) {
        messageLabel.layer.cornerRadius = messageLabel.frame.size.height / 2
        messageLabel.clipsToBounds = true
        
        incomingMessageLabel.layer.cornerRadius = incomingMessageLabel.frame.size.height / 2
        incomingMessageLabel.clipsToBounds = true
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        if isIncoming {
            usernameLabel.text = username
            incomingMessageLabel.text = message
            profileImageView.sd_setImage(with: URL(string: imageUrl))
            incomingMessageLabel.isHidden = false
            messageLabel.isHidden = true
            usernameLabel.isHidden = false
            profileImageView.isHidden = false
        } else {
            messageLabel.text = message
            messageLabel.isHidden = false
            incomingMessageLabel.isHidden = true
            usernameLabel.isHidden = true
            profileImageView.isHidden = true
        }
    }

}
