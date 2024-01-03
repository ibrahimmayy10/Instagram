//
//  StoryTableViewCell.swift
//  Instagram
//
//  Created by İbrahim Ay on 18.12.2023.
//

import UIKit
import Firebase

protocol StoryTableViewCellDelegate: AnyObject {
    func didSelectStory(story: StoryModel)
    func goToGallery()
}

class StoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var storyList = [StoryModel]()
    
    var storyUsernames: [String: String] = [:]
    var storyProfileImageArray: [String: String] = [:]
    
    weak var delegate: StoryTableViewCellDelegate?
    
    var profileImageUrl = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getDataStory()
        getDataUserProfile()
                
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getDataStory() {
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        
        let userRef = firestore.collection("users").document(currentUserID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
                return
            }
            
            if let following = document?.data()?["following"] as? [String] {
                firestore.collection("Story").whereField("postedBy", in: following).getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Hata oluştu: \(error.localizedDescription)")
                        return
                    }
                        
                    guard let documents = snapshot?.documents else { return }
                    
                    let stories = documents.compactMap { document in
                        return StoryModel.createFrom(document.data())
                    }
                    
                    let currentTimestamp = Date().addingTimeInterval(-24 * 60 * 60).timeIntervalSince1970
                    
                    let validStories = stories.filter { story in
                        if let timestamp = story.timestamp?.dateValue().timeIntervalSince1970 {
                            return timestamp >= currentTimestamp
                        }
                        return false
                    }
                    
                    self.storyList = validStories
                    self.getStoryUsername(userIDs: following)
                    self.getDataStoryUserProfile(userIds: following)
                    self.collectionView.reloadData()
                }
            } else {
                print("Takip edilen kullanıcı yok.")
            }
        }
    }
    
    func getStoryUsername(userIDs: [String]) {
        let firestore = Firestore.firestore()
        
        firestore.collection("users").whereField("postedBy", in: userIDs).getDocuments { (snapshot, error) in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    if let userID = document.data()["postedBy"] as? String,
                       let username = document.data()["username"] as? String {
                        self.storyUsernames[userID] = username
                    }
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    func getDataStoryUserProfile(userIds: [String]) {
        let firestore = Firestore.firestore()
        
        firestore.collection("users").whereField("postedBy", in: userIds).getDocuments { (snapshot, error) in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    if let userId = document.data()["postedBy"] as? String,
                       let imageUrl = document.data()["imageUrl"] as? String {
                        self.storyProfileImageArray[userId] = imageUrl
                    }
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    func getDataUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        
        firestore.collection("users").whereField("postedBy", isEqualTo: currentUserID).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    guard let imageUrl = document.get("imageUrl") as? String else { return }
                    self.profileImageUrl = imageUrl
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addStoryCell", for: indexPath) as! AddStoryCollectionViewCell
            
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
            cell.profileImageView.clipsToBounds = true
            
            cell.profileImageView.sd_setImage(with: URL(string: profileImageUrl))
            
            return cell
            
        } else if indexPath.row - 1 < storyList.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! StoryCollectionViewCell
                
            cell.storyImageView.layer.cornerRadius = cell.storyImageView.frame.size.width / 2
            cell.storyImageView.clipsToBounds = true
                
            let story = storyList[indexPath.row - 1]

            if let username = storyUsernames[story.postedBy] {
                cell.storyUsernameLabel.text = username
            }
                
            if let imageUrl = storyProfileImageArray[story.postedBy] {
                cell.storyImageView.sd_setImage(with: URL(string: imageUrl))
            }
                
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.goToGallery()
        } else if indexPath.row - 1 < storyList.count {
            let story = storyList[indexPath.row - 1]
            
            delegate?.didSelectStory(story: story)
        }
    }

}
