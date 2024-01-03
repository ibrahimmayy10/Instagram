//
//  AnasayfaVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 14.10.2023.
//

import UIKit
import Firebase
import SDWebImage
import MobileCoreServices

class HomePageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PostsTableViewCellDelegate, StoryTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [PostModel] = []
    var users: [UserModel] = []
    
    var followingList: [String] = []
    
    var userNames: [String: String] = [:]
    var profileImageArray: [String: String] = [:]
    
    var storyUsernames: [String: String] = [:]
    var storyProfileImageArray: [String: String] = [:]
    
    var storyList = [StoryModel]()
    
    var isStorySelected = false
    
    var firestore = Firestore.firestore()
    var currentUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        currentUserID = Auth.auth().currentUser?.uid
                
        getFollowingPost()
        getDataStory()
        
        Timer.scheduledTimer(timeInterval: 24 * 60 * 60, target: self, selector: #selector(deleteStory), userInfo: nil, repeats: false)
                
    }
    
    func goToGallery() {
        isStorySelected = true
        showImagePicker(mediaType: kUTTypeImage as String)
    }
    
    func didSelectStory(story: StoryModel) {
        let storyDetailsVC = storyboard?.instantiateViewController(identifier: "toStoryDetailsVC") as! StoryDetailsVC
        
        guard let username = storyUsernames[story.postedBy], let profileImageUrl = storyProfileImageArray[story.postedBy] else { return }
        
        storyDetailsVC.userProfileImageUrl = profileImageUrl
        storyDetailsVC.username = username
        storyDetailsVC.storyImageUrl = story.imageUrl
        navigationController?.pushViewController(storyDetailsVC, animated: false)
    }
    
    @objc func deleteStory() {
        let currentTimestamp = Date().timeIntervalSince1970
        let twentyFourHoursAgo = currentTimestamp - (24 * 60 * 60)
        
        firestore.collection("Story").whereField("time", isLessThan: twentyFourHoursAgo).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                let documentID = document.documentID
                
                self.firestore.document(documentID).delete { error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    } else {
                        print("story silme işlemi başarılı")
                    }
                }
            }
            self.tableView.reloadData()
        }
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
                    
//                    let currentTimestamp = Date().addingTimeInterval(-24 * 60 * 60).timeIntervalSince1970
//                    
//                    let validStories = stories.filter { story in
//                        if let timestamp = story.timestamp?.dateValue().timeIntervalSince1970 {
//                            return timestamp >= currentTimestamp
//                        }
//                        return false
//                    }
                    
                    self.storyList = stories
                    self.getStoryUsername(userIDs: following)
                    self.getDataStoryUserProfile(userIds: following)
                    self.tableView.reloadData()
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
                self.tableView.reloadData()
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
                self.tableView.reloadData()
            }
        }
    }
    
    func getFollowingPost() {
        guard let currentUserID = currentUserID else { return }
        
        let userRef = firestore.collection("users").document(currentUserID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
                return
            }
            
            if let following = document?.data()?["following"] as? [String] {
                self.firestore.collection("Posts").whereField("postedBy", in: following).getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Hata oluştu: \(error.localizedDescription)")
                        return
                    }
                        
                    guard let documents = snapshot?.documents else { return }
                    
                    var posts = documents.compactMap { document in
                        return PostModel.createFrom(document.data())
                    }
                    
                    self.posts = posts
                    self.getUserNamesFromFirestore(userIds: following)
                    self.getDataUserProfile(userIds: following)
                    self.tableView.reloadData()
                }
            } else {
                print("Takip edilen kullanıcı yok.")
            }
        }
    }
    
    func getUserNamesFromFirestore(userIds: [String]) {
        firestore.collection("users").whereField("postedBy", in: userIds).getDocuments { (snapshot, error) in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    if let userId = document.data()["postedBy"] as? String,
                       let username = document.data()["username"] as? String {
                        self.userNames[userId] = username
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getDataUserProfile(userIds: [String]) {
        firestore.collection("users").whereField("postedBy", in: userIds).getDocuments { (snapshot, error) in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    if let userId = document.data()["postedBy"] as? String,
                       let imageUrl = document.data()["imageUrl"] as? String {
                        self.profileImageArray[userId] = imageUrl
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func didTapCommentButton(at cell: PostsTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let post = posts[indexPath.row]
            let postCommentVC = self.storyboard?.instantiateViewController(withIdentifier: "toPostCommentVC") as! PostCommentVC
            postCommentVC.postId = post.postId
            present(postCommentVC, animated: true)
        }
    }
    
    @IBAction func notificationButton(_ sender: Any) {
    }
    
    @IBAction func dmButton(_ sender: Any) {
        let dm = storyboard?.instantiateViewController(identifier: "toDmPersonVC") as! DMPersonsVC
        navigationController?.pushViewController(dm, animated: true)
    }
    
    @IBAction func searchButton(_ sender: Any) {
        let searchVC = storyboard?.instantiateViewController(identifier: "toSearchVC") as! SearchVC
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    @IBAction func postAddButton(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Fotoğraf", style: .default, handler: { action in
            self.isStorySelected = false
            self.showImagePicker(mediaType: kUTTypeImage as String)
        }))

        alert.addAction(UIAlertAction(title: "Reels", style: .default, handler: { action in
            self.isStorySelected = false
            self.showImagePicker(mediaType: kUTTypeMovie as String)
        }))

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func showImagePicker(mediaType: String) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [mediaType]

        if mediaType == kUTTypeImage as String && !isStorySelected {
            imagePicker.allowsEditing = true
        }

        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedVideoUrl = info[.mediaURL] as? URL {
            let videoVC = storyboard?.instantiateViewController(identifier: "toEditVideoVC") as! EditVideoVC
            videoVC.videoUrl = selectedVideoUrl
            navigationController?.pushViewController(videoVC, animated: false)
        } else if let selectedImage = info[.originalImage] as? UIImage {
            if isStorySelected {
                guard let storyVC = self.storyboard?.instantiateViewController(identifier: "toStoryVC") as? StoryVC else { return }
                self.dismiss(animated: true)
                storyVC.selectedImage = selectedImage
                self.navigationController?.pushViewController(storyVC, animated: true)
            } else {
                guard let postVC = self.storyboard?.instantiateViewController(identifier: "toEditPostVC") as? EditPostVC else { return }
                self.dismiss(animated: true)
                postVC.selectedImage = selectedImage
                self.navigationController?.pushViewController(postVC, animated: true)
            }
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func reelsButton(_ sender: Any) {
        let reelsVC = storyboard?.instantiateViewController(identifier: "toReelsVC") as! ReelsVC
        navigationController?.pushViewController(reelsVC, animated: false)
    }
    
    @IBAction func accountButton(_ sender: Any) {
        let accountVC = storyboard?.instantiateViewController(identifier: "toAccountVC") as! AccountVC
        navigationController?.pushViewController(accountVC, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as! StoryTableViewCell
            cell.delegate = self
            return cell
            
        } else if indexPath.row - 1 < posts.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostsTableViewCell
            
            let selectedView = UIView()
            selectedView.backgroundColor = UIColor.black
            cell.selectedBackgroundView = selectedView
            
            cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.size.width / 2
            cell.userProfileImageView.clipsToBounds = true
            
            let post = posts[indexPath.row - 1]
            cell.postExplanationLabel.text = post.explanation
            
            if let username = userNames[post.postedBy] {
                cell.usernameLabel.text = username
            }
            
            cell.postImageView.sd_setImage(with: URL(string: post.imageUrl))
            cell.postId = post.postId
            
            if let imageUrl = profileImageArray[post.postedBy] {
                cell.userProfileImageView.sd_setImage(with: URL(string: imageUrl))
            }
            
            cell.delegate = self

            firestore.collection("Likes").whereField("postId", isEqualTo: post.postId).getDocuments { documents, error in
                if error != nil {
                    print("HATA: \(error?.localizedDescription ?? "")")
                } else if let document = documents?.documents {
                    cell.likeLabel.text = "\(String(document.count)) kişi beğendi"
                    
                    cell.likeBtn.setImage(document.contains { $0["postedBy"] as? String == self.currentUserID } ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)
                    cell.likeBtn.tintColor = document.contains { $0["postedBy"] as? String == self.currentUserID } ? .red : .white
                    cell.likeBtn.tag = document.contains { $0["postedBy"] as? String == self.currentUserID } ? 1 : 0
                }
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 173
        } else {
            return 650
        }
    }
    
}
