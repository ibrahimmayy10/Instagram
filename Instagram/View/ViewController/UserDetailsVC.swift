//
//  UserDetailsVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 17.10.2023.
//

import UIKit
import Firebase
import SDWebImage

class UserDetailsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followedLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var username = String()
    var selectedImage = String()
    var postedBy = String()
    var name = String()
    
    var postListUrl = [String]()
    var explanationArray = [String]()
    var postId = [String]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        write()
        getDataFollowers()
        getDataFollowing()
        updateFollowButton()
        getDataUserPost()
        getDataUserInfo()

    }
    
    func getDataUserInfo() {
        let firestore = Firestore.firestore()
        
        firestore.collection("users").whereField("postedBy", isEqualTo: postedBy).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    guard let name = document.get("name") as? String, let biography = document.get("biography") as? String else { return }
                    self.nameLabel.text = name
                    self.biographyLabel.text = biography
                }
            }
        }
    }
    
    func getDataUserPost () {
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Posts").whereField("postedBy", isEqualTo: postedBy).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                for document in documents {
                    guard let imageUrl = document.get("image") as? String, let explanation = document.get("explanation") as? String, let postId = document.get("postId") as? String else { return }
                    self.postListUrl.append(imageUrl)
                    self.explanationArray.append(explanation)
                    self.postId.append(postId)
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func updateFollowButton() {
        let firestoreDatabase = Firestore.firestore()
            
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        
        firestoreDatabase.collection("users").document(postedBy).getDocument { (snapshot, error) in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else if let documents = snapshot, documents.exists {
                
                let followingList = documents.data()?["follower"] as? [String] ?? []
                
                if followingList.contains(currentUserId) {
                    self.followBtn.setTitle("Takiptesin", for: .normal)
                }
            }
        }
    }
    
    func getDataFollowing () {
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("users").document(postedBy).getDocument { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else if let document = snapshot, document.exists {
                
                let followingCount = document.data()?["following"] as? [String] ?? []
                let following = followingCount.count
                self.followedLabel.text = String(following)
            }
        }
    }
    
    func getDataFollowers () {
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("users").document(postedBy).getDocument { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else if let document = snapshot, document.exists {
                
                let followers = document.data()?["follower"] as? [String] ?? []
                let followerCount = followers.count
                self.followerLabel.text = String(followerCount)
            }
        }
    }
    
    func write () {
        usernameLabel.text = username
        imageView.sd_setImage(with: URL(string: selectedImage))
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButton(_ sender: Any) {
    }
    
    @IBAction func followButton(_ sender: Any) {
        if followBtn.tag == 0 {
            followBtn.setTitle("Takiptesin", for: .normal)
            followBtn.tag = 1
            
            let firestoreDatabase = Firestore.firestore()
            
            guard let user = Auth.auth().currentUser else { return }
            let currentUserID = user.uid
                        
            let currentUserReference = firestoreDatabase.collection("users").document(currentUserID)
            
            firestoreDatabase.collection("users").document(postedBy).getDocument { document, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else if let document = document, document.exists {
                    var followingList = document.data()?["follower"] as? [String] ?? []
                    
                    if !followingList.contains(currentUserID) {
                        followingList.append(currentUserID)
                        firestoreDatabase.collection("users").document(self.postedBy).updateData(["follower": followingList])
                    }
                    
                    self.followerLabel.text = String(followingList.count)
                    
                    var currentUserFollowingList: [String] = []
                    
                    currentUserReference.getDocument { snapshot, error in
                        if error != nil {
                            print(error?.localizedDescription ?? "")
                            return
                        }
                        
                        if let document = snapshot, document.exists {
                            if let currentUserData = document.data() {
                                currentUserFollowingList = currentUserData["following"] as? [String] ?? []
                            }
                        }
                        
                        currentUserFollowingList.append(self.postedBy)
                        currentUserReference.updateData(["following": currentUserFollowingList])
                    }
                }
            }
            
        } else {
            let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "Takibi Bırak", style: .default, handler: { action in
                self.followBtn.setTitle("Takip Et", for: .normal)
                self.followBtn.tag = 0

                let firestoreDatabase = Firestore.firestore()
                guard let user = Auth.auth().currentUser else { return }
                let currentUserID = user.uid

                let currentUserReference = firestoreDatabase.collection("users").document(currentUserID)

                firestoreDatabase.collection("users").document(self.postedBy).updateData(["follower": FieldValue.arrayRemove([currentUserID])]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.followerLabel.text = String((Int(self.followerLabel.text ?? "") ?? 0) - 1)
                        currentUserReference.updateData(["following": FieldValue.arrayRemove([self.postedBy])])
                    }
                }
            }))

            alert.addAction(UIAlertAction(title: "Kapat", style: .cancel))

            present(alert, animated: true)
        }
    }
    
    @IBAction func messageButton(_ sender: Any) {
        let dmVC = storyboard?.instantiateViewController(identifier: "toDmVC") as! DmVC
        dmVC.postedBy = postedBy
        dmVC.name = name
        dmVC.imageUrl = selectedImage
        navigationController?.pushViewController(dmVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postListUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchUserCell", for: indexPath) as! SearchUserPostsCollectionViewCell
        let postImage = postListUrl[indexPath.row]
        cell.searchUserImageView.sd_setImage(with: URL(string: postImage))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postDetailsVC = storyboard?.instantiateViewController(identifier: "toPostDetailsVC") as! PostDetailsVC
        postDetailsVC.username = username
        postDetailsVC.imageUrlArray = postListUrl
        postDetailsVC.explanationArray = explanationArray
        postDetailsVC.postId = postId
        postDetailsVC.imageUrl = selectedImage
        navigationController?.pushViewController(postDetailsVC, animated: true)
    }
    
}
