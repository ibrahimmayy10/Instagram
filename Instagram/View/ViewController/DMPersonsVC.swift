//
//  DMPersonsVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 28.10.2023.
//

import UIKit
import Firebase

class DMPersonsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var followList = [FollowingModel]()
    var groupList = [MessageRoomModel]()
    var combinedList = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFollowing()
        getDataUsername()
        getDataGroup()
        
        combinedList += followList
        combinedList += groupList
        
    }
    
    func getDataGroup() {
        let firestoreDatabase = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestoreDatabase.collection("MessageRoom").whereField("users", arrayContains: currentUserID).addSnapshotListener { snapshot, error in
            if error != nil {
                print("GRUP ÇEKİLEMEDİ: \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var groupList = [MessageRoomModel]()
            
            for document in documents {
                guard let chatRoomID = document["chatRoomID"] as? String, let users = document["users"] as? [String], let groupName = document["groupName"] as? String else { return }
                let group = MessageRoomModel(chatRoomID: chatRoomID, users: users, groupName: groupName)
                groupList.append(group)
            }
            self.groupList = groupList
            self.tableView.reloadData()
        }
    }
    
    func getDataUsername() {
        let firestoreDatabase = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestoreDatabase.collection("users").whereField("postedBy", isEqualTo: currentUserID).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    guard let username = document.get("username") as? String else { return }
                    self.usernameLabel.text = username
                }
            }
        }
    }
    
    func getDataFollowing() {
        let firestoreDatabase = Firestore.firestore()

        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid

        firestoreDatabase.collection("users").whereField("postedBy", isEqualTo: currentUserID).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents, !documents.isEmpty {
                let userDoc = documents[0]

                let followingList = userDoc.data()["following"] as? [String] ?? []

                var usersData = [FollowingModel]()

                for userID in followingList {
                    firestoreDatabase.collection("users").document(userID).getDocument { userSnapshot, userError in
                        if let userError = userError {
                            print("Kullanıcı verilerini alırken hata oluştu: \(userError.localizedDescription)")
                        } else if let userData = userSnapshot?.data() {
                            if let username = userData["name"] as? String,
                               let profileImageURL = userData["imageUrl"] as? String, let postedBy = userData["postedBy"] as? String {
                                let user = FollowingModel(name: username, imageUrl: profileImageURL, postedBy: postedBy)
                                usersData.append(user)
                            }
                        }
                        self.followList = usersData
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return followList.count
        } else if section == 1 {
            return groupList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dmPersonCell", for: indexPath) as! PersonsTableViewCell
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = selectedView
        
        if indexPath.section == 0 {
            let users = followList[indexPath.row]
            cell.dmPersonNameLabel.text = users.name
            
            cell.dmPersonImageVİew.layer.cornerRadius = cell.dmPersonImageVİew.layer.frame.width / 2
            cell.dmPersonImageVİew.clipsToBounds = true
            
            cell.dmPersonImageVİew.sd_setImage(with: URL(string: users.imageUrl))
        } else if indexPath.section == 1 {
            let users = groupList[indexPath.row]
            
            cell.dmPersonNameLabel.text = users.groupName
            cell.dmPersonImageVİew.image = UIImage(systemName: "person.2.fill")
            cell.dmPersonImageVİew.tintColor = .darkGray
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let users = followList[indexPath.row]
            
            let dmVC = storyboard?.instantiateViewController(identifier: "toDmVC") as! DmVC
            dmVC.name = users.name
            dmVC.imageUrl = users.imageUrl
            dmVC.postedBy = users.postedBy
            navigationController?.pushViewController(dmVC, animated: true)
        } else if indexPath.section == 1 {
            let group = groupList[indexPath.row]
            
            let groupMessageVC = storyboard?.instantiateViewController(identifier: "toGroupMessageVC") as! GroupMessageVC
            groupMessageVC.groupName = group.groupName
            groupMessageVC.chatRoomID = group.chatRoomID
            navigationController?.pushViewController(groupMessageVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }

    @IBAction func groupButton(_ sender: Any) {
        let groupVC = storyboard?.instantiateViewController(identifier: "toGroupPersonVC") as! GroupPersonVC
        navigationController?.pushViewController(groupVC, animated: true)
    }
    
}
