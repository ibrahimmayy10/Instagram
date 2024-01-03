//
//  ReelsCommentTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 5.11.2023.
//

import UIKit

class ReelsCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var reelsCommentUsernameLabel: UILabel!
    @IBOutlet weak var reelsCommentLabel: UILabel!
    @IBOutlet weak var reelsCommentUserProfileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
