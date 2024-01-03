//
//  PersonsTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 28.10.2023.
//

import UIKit

class PersonsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dmPersonImageVİew: UIImageView!
    @IBOutlet weak var dmPersonNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        dmPersonImageVİew.layer.cornerRadius = dmPersonImageVİew.frame.size.width / 2
        dmPersonImageVİew.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
