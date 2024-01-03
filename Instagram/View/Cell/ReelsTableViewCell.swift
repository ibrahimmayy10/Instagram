//
//  ReelsTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 22.10.2023.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

protocol ReelsTableViewCellDelegate: class {
    func didTapReelsCommentButton(at cell: ReelsTableViewCell)
    func sendReelsButton(at cell: ReelsTableViewCell)
}

class ReelsTableViewCell: UITableViewCell {
        
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var reelsUsernameLabel: UILabel!
    @IBOutlet weak var reelsExplanationLabel: UILabel!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var reelsVC: ReelsVC?
    
    var reelsId: String?
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    weak var delegate: ReelsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
    }
    
    func configure(with videoURLString: String) {
        if let videoURL = URL(string: videoURLString) {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = contentView.bounds
            playerLayer?.videoGravity = .resizeAspectFill
            contentView.layer.addSublayer(playerLayer!)
            player?.play()
        }
    }
    
    @IBAction func likeButton(_ sender: Any) {
        if likeBtn.tag == 0 {
            likeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeBtn.tag = 1
            likeBtn.tintColor = .red
            
            let firestore = Firestore.firestore()
            
            guard let user = Auth.auth().currentUser, let reelsId = reelsId else { return }
            let currentUserID = user.uid
            
            let firestoreLikes = ["postedBy": currentUserID, "reelsId": reelsId] as [String: Any]
            
            firestore.collection("ReelsLikes").addDocument(data: firestoreLikes) { error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else {
                    firestore.collection("ReelsLikes").whereField("reelsId", isEqualTo: reelsId).getDocuments { snapshot, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                        } else if let documents = snapshot?.documents {
                            self.likeLabel.text = String(documents.count)
                        }
                    }
                }
            }
        } else {
            likeBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            likeBtn.tintColor = .white
            likeBtn.tag = 0
            
            let firestore = Firestore.firestore()
            
            guard let user = Auth.auth().currentUser, let reelsId = reelsId else { return }
            let currentUserID = user.uid
            
            firestore.collection("ReelsLikes").whereField("postedBy", isEqualTo: currentUserID).whereField("reelsId", isEqualTo: reelsId).getDocuments { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents {
                    for document in documents {
                        document.reference.delete()
                    }
                    firestore.collection("ReelsLikes").whereField("reelsId", isEqualTo: reelsId).getDocuments { documents, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                        } else if let documents = documents?.documents {
                            self.likeLabel.text = String(documents.count)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func commentButton(_ sender: Any) {
        delegate?.didTapReelsCommentButton(at: self)
    }
    
    @IBAction func sendButton(_ sender: Any) {
        delegate?.sendReelsButton(at: self)
    }
    
}
