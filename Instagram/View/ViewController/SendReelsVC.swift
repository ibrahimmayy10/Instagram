//
//  SendReelsVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 28.11.2023.
//

import UIKit
import Firebase

class SendReelsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    
    var followList = [FollowingModel]()
    var allReels = [SendReelsModel]()

    var videoUrl = String()
    
    var postedByList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchTextField.layer.cornerRadius = searchTextField.frame.size.height / 2
        searchTextField.clipsToBounds = true
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Ara...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        messageTextField.attributedPlaceholder = NSAttributedString(string: "Mesaj yaz...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        getDataFollowing()
        
    }
    
    func getDataFollowing() {
        let firestore = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestore.collection("users").whereField("postedBy", isEqualTo: currentUserID).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                let userDoc = documents[0]
                
                let followingList = userDoc.data()["following"] as? [String] ?? []
                
                var usersData = [FollowingModel]()
                
                for userID in followingList {
                    firestore.collection("users").document(userID).getDocument { userSnapshot, error in
                        if let error = error {
                            print("Kullanıcı verilerini alırken hata oluştu: \(error.localizedDescription)")
                        } else if let userData = userSnapshot?.data() {
                            guard let name = userData["name"] as? String, let imageUrl = userData["imageUrl"] as? String, let postedBy = userData["postedBy"] as? String else { return }
                            let user = FollowingModel(name: name, imageUrl: imageUrl, postedBy: postedBy)
                            usersData.append(user)
                        }
                        self.followList = usersData
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }

    @IBAction func sendButton(_ sender: Any) {
        
        guard !postedByList.isEmpty else { return }
        print(postedByList.count)
        
        guard let message = messageTextField.text else { return }
        messageTextField.text = ""

        saveReelsMessage(message: message, videoUrl: videoUrl)
    }
    
    func saveReelsMessage(message: String, videoUrl: String) {
        let firestore = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        for postedBy in postedByList {
            let chatRoomID = generateChatRoomID(user1: currentUserID, user2: postedBy)
            
            let firestoreMessage = ["message": message, "videoUrl": videoUrl, "senderID": currentUserID, "postedBy": postedBy, "time": FieldValue.serverTimestamp()] as [String: Any]
            
            firestore.collection("Messages").document(chatRoomID).collection("Message").document().setData(firestoreMessage) { error in
                if error != nil {
                    print("reels göndermede hata oluştu: \(error?.localizedDescription ?? "")")
                } else {
                    print("reels gönderme başarılı")
                }
            }
        }
    }
    
    func generateChatRoomID(user1: String, user2: String) -> String {
        let sortedIDs = [user1, user2].sorted()
        return sortedIDs.joined(separator: "_")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return followList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sendReelsCell", for: indexPath) as! SendReelsCollectionViewCell
        
        cell.selectedImageView.isHidden = true
        
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.height / 2
        cell.profileImageView.clipsToBounds = true
        
        let followingList = followList[indexPath.row]
        cell.nameLabel.text = followingList.name
        cell.profileImageView.sd_setImage(with: URL(string: followingList.imageUrl))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SendReelsCollectionViewCell
        cell.selectedImageView.isHidden = false
        let followingList = followList[indexPath.row]
        self.postedByList.append(followingList.postedBy)
    }
    
}
