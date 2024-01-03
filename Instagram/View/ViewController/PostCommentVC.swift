//
//  PostCommentVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 4.11.2023.
//

import UIKit
import Firebase

class PostCommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    var postId = String()
    
    var firestore = Firestore.firestore()
    var currentUserID = String()
    
    var commentArray = [String]()
    var usernameArray = [String]()
    var imageUrlArray = [String]()
    
    var username = String()
    var imageUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        commentTextField.layer.cornerRadius = commentTextField.frame.size.height / 2
        commentTextField.clipsToBounds = true
        commentTextField.attributedPlaceholder = NSAttributedString(string: "Yorum ekle...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        currentUserID = Auth.auth().currentUser?.uid ?? ""
        
        getDataUsername()
        getDataComment()
                        
    }
    
    func getDataUsername() {
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
        
        firestore.collection("PostComments").whereField("postId", isEqualTo: postId).order(by: "time").addSnapshotListener { snapshot, error in
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "")")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    guard let comment = document.get("comment") as? String, let username = document.get("username") as? String, let imageUrl = document.get("imageUrl") as? String else { return }
                    self.commentArray.append(comment)
                    self.usernameArray.append(username)
                    self.imageUrlArray.append(imageUrl)
                }
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func shareButton(_ sender: Any) {
        var comment = commentTextField.text
        var firestoreComment = ["comment": comment, "postedBy": currentUserID, "postId": postId, "username": username, "imageUrl": imageUrl, "time": FieldValue.serverTimestamp()] as [String: Any]
        
        firestore.collection("PostComments").addDocument(data: firestoreComment) { error in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCommentCell", for: indexPath) as! PostCommentTableViewCell
        cell.commentsLabel.text = commentArray[indexPath.row]
        cell.usernameLabel.text = usernameArray[indexPath.row]
        
        cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.size.width / 2
        cell.userProfileImageView.clipsToBounds = true
        
        cell.userProfileImageView.sd_setImage(with: URL(string: imageUrlArray[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
}
