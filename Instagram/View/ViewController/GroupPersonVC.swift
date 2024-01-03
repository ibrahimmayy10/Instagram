//
//  GroupPersonVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 2.11.2023.
//

import UIKit
import Firebase
import SDWebImage

class GroupPersonVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var followList = [FollowingModel]()
    var userList = [String]()
    var nameList = [String]()
    var chatRoomID = String()
    
    var currentUserID: String?
    var firestoreDatabase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFollowing()
        
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
    
    @IBAction func createGroupButton(_ sender: Any) {
        let createGroupVC = self.storyboard?.instantiateViewController(identifier: "toCreateGroupVC") as! CreateGroupVC
        createGroupVC.chatRoomID = chatRoomID
        createGroupVC.userList = userList
        createGroupVC.nameList = nameList
        self.navigationController?.pushViewController(createGroupVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupPersonTableViewCell
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = selectedView
        
        let user = followList[indexPath.row]
        cell.groupUsernameLabel.text = user.name
        cell.groupImageView.sd_setImage(with: URL(string: user.imageUrl))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? GroupPersonTableViewCell {
            if cell.groupCircleImageView.image == UIImage(systemName: "circle") {
                cell.groupCircleImageView.image = UIImage(systemName: "checkmark.circle.fill")
                cell.groupCircleImageView.tintColor = .tintColor
                
                let users = followList[indexPath.row]
                self.userList.append(users.postedBy)
                self.nameList.append(users.name)
            } else {
                cell.groupCircleImageView.image = UIImage(systemName: "circle")
                cell.groupCircleImageView.tintColor = .darkGray
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89
    }
    
}
