//
//  SearchUserTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 17.10.2023.
//

import UIKit

class SearchUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchNameLabel: UILabel!
    @IBOutlet weak var searchUsernameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
