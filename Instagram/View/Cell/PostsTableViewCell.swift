//
//  PostsTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 14.10.2023.
//

import UIKit
import Firebase

protocol PostsTableViewCellDelegate: class {
    func didTapCommentButton(at cell: PostsTableViewCell)
}

class PostsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postExplanationLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    
    var like = 0
    var postId: String?
    
    weak var delegate: PostsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(likePost))
        doubleTapRecognizer.numberOfTapsRequired = 2
        postImageView.addGestureRecognizer(doubleTapRecognizer)
        postImageView.isUserInteractionEnabled = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    @objc func likePost() {
        likeButton(self)
        showHeartAnimation()
    }
    
    func showHeartAnimation() {
        let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartImageView.tintColor = .red
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        heartImageView.center = postImageView.center
        heartImageView.alpha = 0.0
        
        postImageView.addSubview(heartImageView)
        
        UIView.animate(withDuration: 0.2, animations: {
            heartImageView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 1.0, delay: 0.5, options: [], animations: {
                heartImageView.alpha = 0.0
            }, completion: { _ in
                heartImageView.removeFromSuperview()
            })
        }
    }
    
    @IBAction func likeButton(_ sender: Any) {
        if likeBtn.tag == 0 {
            likeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeBtn.tintColor = .red
            likeBtn.tag = 1
            
            let firestoreDatabase = Firestore.firestore()
                    
            guard let currentUser = Auth.auth().currentUser, let postId = postId else { return }
            let currentUserId = currentUser.uid
            
            let firestoreLikes = ["postedBy": currentUserId,"postId": postId] as [String: Any]
            
            firestoreDatabase.collection("Likes").addDocument(data: firestoreLikes) { error in
                if error != nil {
                    print("HATA: \(error?.localizedDescription ?? "")")
                } else {
                    firestoreDatabase.collection("Likes").whereField("postId", isEqualTo: postId).getDocuments { documents, error in
                        if error != nil {
                            print("HATA: \(error?.localizedDescription ?? "")")
                        } else if let document = documents?.documents {
                            self.likeLabel.text = "\(String(document.count)) kişi beğendi"
                        }
                    }
                }
            }
        } else {
            likeBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            likeBtn.tintColor = .white
            likeBtn.tag = 0
            
            let firestoreDatabase = Firestore.firestore()
            
            guard let user = Auth.auth().currentUser, let postId = postId else { return }
            let currentUserId = user.uid
            
            firestoreDatabase.collection("Likes").whereField("postedBy", isEqualTo: currentUserId).whereField("postId", isEqualTo: postId).getDocuments { snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let documents = snapshot?.documents {
                    for document in documents {
                        document.reference.delete()
                    }
                    firestoreDatabase.collection("Likes").whereField("postId", isEqualTo: postId).getDocuments { documents, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                        } else if let documents = documents?.documents {
                            self.likeLabel.text = "\(String(documents.count)) kişi beğendi"
                        }
                    }
                }
            }
        }
    }

    @IBAction func commentButton(_ sender: Any) {
        delegate?.didTapCommentButton(at: self)
    }
    
}
