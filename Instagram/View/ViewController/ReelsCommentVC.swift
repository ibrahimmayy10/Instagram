//
//  ReelsCommentVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 5.11.2023.
//

import UIKit
import Firebase

class ReelsCommentVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var reelsId = String()
    
    var firestore = Firestore.firestore()
    var currentUserID = String()
    
    var username = String()
    var imageUrl = String()
    var usernameArray = [String]()
    var imageUrlArray = [String]()
    var commentArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        commentTextField.layer.cornerRadius = commentTextField.frame.size.height / 2
        commentTextField.clipsToBounds = true
        commentTextField.attributedPlaceholder = NSAttributedString(string: "Yorum ekle...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        currentUserID = Auth.auth().currentUser?.uid ?? ""
        
        getDataUserInfo()
        getDataComment()
        
    }
    
    func getDataUserInfo() {
        firestore.collection("users").whereField("postedBy", isEqualTo: currentUserID).getDocuments { (snapshot, error) in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    if let username = document.data()["username"] as? String, let imageUrl = document.data()["imageUrl"] as? String {
                        self.username = username
                        self.imageUrl = imageUrl
                    }
                }
            }
        }
    }
    
    func getDataComment() {
        usernameArray.removeAll()
        imageUrlArray.removeAll()
        commentArray.removeAll()
        
        firestore.collection("ReelsComments").whereField("reelsId", isEqualTo: reelsId).order(by: "time").addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    guard let username = document.get("username") as? String, let imageUrl = document.get("imageUrl") as? String, let comment = document.get("comment") as? String else { return }
                    self.usernameArray.append(username)
                    self.imageUrlArray.append(imageUrl)
                    self.commentArray.append(comment)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func shareButton(_ sender: Any) {
        var comment = commentTextField.text
        
        var firestoreComment = ["comment": comment, "reelsId": reelsId, "postedBy": currentUserID, "username": username, "imageUrl": imageUrl, "time": FieldValue.serverTimestamp()] as [String: Any]
        
        firestore.collection("ReelsComments").addDocument(data: firestoreComment) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("yorum atma başarılı")
                self.commentTextField.text = ""
                self.getDataComment()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reelsCommentCell", for: indexPath) as! ReelsCommentTableViewCell
        cell.reelsCommentUsernameLabel.text = usernameArray[indexPath.row]
        cell.reelsCommentLabel.text = commentArray[indexPath.row]
        
        cell.reelsCommentUserProfileImageView.layer.cornerRadius = cell.reelsCommentUserProfileImageView.frame.size.width / 2
        cell.reelsCommentUserProfileImageView.clipsToBounds = true
        
        cell.reelsCommentUserProfileImageView.sd_setImage(with: URL(string: imageUrlArray[indexPath.row]))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
}
