//
//  PostDetailsTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 5.11.2023.
//

import UIKit

protocol PostDetailsTableViewCellDelegate: class {
    func didTapCommentButton(at cell: PostDetailsTableViewCell)
}

class PostDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postDetailsUsernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var postDetailsImageView: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
        
    weak var delegate: PostDetailsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeButton(_ sender: Any) {
    }
    
    @IBAction func commentButton(_ sender: Any) {
        delegate?.didTapCommentButton(at: self)
    }
    
}
