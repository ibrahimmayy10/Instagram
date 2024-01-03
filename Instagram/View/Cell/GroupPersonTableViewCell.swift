//
//  GroupPersonTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 2.11.2023.
//

import UIKit

class GroupPersonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var groupCircleImageView: UIImageView!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupUsernameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        groupImageView.layer.cornerRadius = groupImageView.frame.size.width / 2
        groupImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
