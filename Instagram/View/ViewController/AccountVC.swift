//
//  AccountVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 15.10.2023.
//

import UIKit
import Firebase
import SDWebImage
import MobileCoreServices

class AccountVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followedLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    
    var imageArray = [String]()
    
    var username = String()
    var explanationArray = [String]()
    var postId = [String]()
    var imageUrl = String()
    
    var isStorySelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width / 2
        userProfileImageView.clipsToBounds = true
        
        getDataUserFirestore()
        getDataUserProfile()
        getDataPostFirestore()
        getDataFollowers()
        getDataFollowing()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture: )))
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.isUserInteractionEnabled = true
        
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                showLongPressAlert(at: indexPath)
            }
        }
    }
    
    func showLongPressAlert(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Gönderiyi sil", style: .destructive, handler: { action in
            let postIDToDelete = self.postId[indexPath.row]
            let postImageUrlDelete = self.imageArray[indexPath.row]
            self.deletePost(postId: postIDToDelete, imageUrl: postImageUrlDelete)
        }))

        alert.addAction(UIAlertAction(title: "Kapat", style: .cancel))

        present(alert, animated: true)
    }
    
    func deletePost(postId: String, imageUrl: String) {
        let firestore = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestore.collection("Posts").whereField("postedBy", isEqualTo: currentUserID).whereField("postId", isEqualTo: postId).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    document.reference.delete()
                }
                
                print("post silme işlemi başarılı")
                
                self.deleteImageFromStorage(imageUrl: imageUrl)
                       
                if let index = self.postId.firstIndex(of: postId) {
                    self.postId.remove(at: index)
                    self.imageArray.remove(at: index)
                    self.explanationArray.remove(at: index)
                    self.collectionView.reloadData()
                }
                
            }
        }
    }
    
    func deleteImageFromStorage(imageUrl: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: imageUrl)

        storageRef.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("resim storage dan silindi")
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func getDataFollowers () {
        let firestoreDatabase = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestoreDatabase.collection("users").whereField("postedBy", isEqualTo: currentUserID).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else if let document = snapshot?.documents, !document.isEmpty {
                let userDoc = document[0]
                
                let followers = userDoc.data()["follower"] as? [String] ?? []
                self.followerLabel.text = String(followers.count)
            }
        }
    }
    
    func getDataFollowing () {
        let firestoreDatabase = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestoreDatabase.collection("users").whereField("postedBy", isEqualTo: currentUserID).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else if let document = snapshot?.documents, !document.isEmpty {
                let userDoc = document[0]
                
                let followingCount = userDoc.data()["following"] as? [String] ?? []
                let following = followingCount.count
                self.followedLabel.text = String(following)
            }
        }
    }
    
    func getDataUserFirestore () {
        let firestoreDatabase = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestoreDatabase.collection("users").whereField("postedBy", isEqualTo: currentUserID).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if !(snapshot?.isEmpty ?? true) {
                    for document in snapshot!.documents {
                        guard let username = document.get("username") as? String, let name = document.get("name") as? String, let biography = document.get("biography") as? String else { return }
                        
                        self.nameLabel.text = name
                        self.usernameLabel.text = username
                        self.biographyLabel.text = biography
                        self.username = username
                    }
                }
            }
        }
    }
    
    func getDataPostFirestore () {
        let firestoreDatabase = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestoreDatabase.collection("Posts").whereField("postedBy", isEqualTo: currentUserID).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                if !(snapshot?.isEmpty ?? true) {
                    for document in snapshot!.documents {
                        if let image = document.get("image") as? String, let explanation = document.get("explanation") as? String, let postId = document.get("postId") as? String {
                            if !self.postId.contains(postId) {
                                self.imageArray.append(image)
                                self.explanationArray.append(explanation)
                                self.postId.append(postId)
                            } else {
                                self.postId.remove(at: self.postId.firstIndex(of: postId)!)
                            }
                        }
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func getDataUserProfile() {
        let firestoreDatabase = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestoreDatabase.collection("users").whereField("postedBy", isEqualTo: currentUserID).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if !(snapshot?.isEmpty ?? true) {
                    for document in snapshot!.documents {
                        if let imageUrl = document.get("imageUrl") as? String {
                            self.userProfileImageView.sd_setImage(with: URL(string: imageUrl))
                            self.imageUrl = imageUrl
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        let editProfileVC = storyboard?.instantiateViewController(identifier: "toEditProfileVC") as! EditProfileVC
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let settingsVC = storyboard?.instantiateViewController(identifier: "toSettingsVC") as! SettingsVC
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func homePageButton(_ sender: Any) {
        let homeVC = storyboard?.instantiateViewController(identifier: "toHomePageVC") as! HomePageVC
        navigationController?.pushViewController(homeVC, animated: false)
    }
    
    @IBAction func searchButton(_ sender: Any) {
        let searchVC = storyboard?.instantiateViewController(identifier: "toSearchVC") as! SearchVC
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    @IBAction func addPostButton(_ sender: Any) {
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
            let postVC = storyboard?.instantiateViewController(identifier: "toEditPostVC") as! EditPostVC
            self.dismiss(animated: true)
            postVC.selectedImage = selectedImage
            navigationController?.pushViewController(postVC, animated: false)
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func reelsButton(_ sender: Any) {
        let reelsVC = storyboard?.instantiateViewController(identifier: "toReelsVC") as! ReelsVC
        navigationController?.pushViewController(reelsVC, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userPostCell", for: indexPath) as! UserPostsCollectionViewCell
        cell.imageView.sd_setImage(with: URL(string: imageArray[indexPath.row]))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postDetailsVC = storyboard?.instantiateViewController(identifier: "toPostDetailsVC") as! PostDetailsVC
        postDetailsVC.username = username
        postDetailsVC.imageUrlArray = imageArray
        postDetailsVC.explanationArray = explanationArray
        postDetailsVC.postId = postId
        postDetailsVC.imageUrl = imageUrl
        navigationController?.pushViewController(postDetailsVC, animated: true)
    }

}
