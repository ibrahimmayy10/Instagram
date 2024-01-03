//
//  PostDetailsVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 5.11.2023.
//

import UIKit
import MobileCoreServices
import SDWebImage
import Firebase

class PostDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, PostDetailsTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var username = String()
    var imageUrlArray = [String]()
    var explanationArray = [String]()
    var postId = [String]()
    var like = Int()
    var imageUrl = String()
    
    var firestore = Firestore.firestore()
    
    var currentUserID = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        currentUserID = Auth.auth().currentUser?.uid ?? ""
        
        usernameLabel.text = username
                
    }
    
    func didTapCommentButton(at cell: PostDetailsTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let postId = postId[indexPath.row]
            let postCommentVC = storyboard?.instantiateViewController(identifier: "toPostCommentVC") as! PostCommentVC
            postCommentVC.postId = postId
            present(postCommentVC, animated: true)
        }
    }

    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Reels", style: .default, handler: { action in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        self.present(alert, animated: true)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageUrlArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postDetailsCell", for: indexPath) as! PostDetailsTableViewCell
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = selectedView
        
        cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.size.width / 2
        cell.userProfileImageView.clipsToBounds = true
        
        cell.userProfileImageView.sd_setImage(with: URL(string: imageUrl))
        
        let imageURL = imageUrlArray[indexPath.row]
        cell.postDetailsImageView.sd_setImage(with: URL(string: imageURL))
        
        cell.postDetailsUsernameLabel.text = username
        cell.explanationLabel.text = explanationArray[indexPath.row]
        
        cell.delegate = self
        
        let postId = postId[indexPath.row]
        
        firestore.collection("Likes").whereField("postId", isEqualTo: postId).getDocuments { documents, error in
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 650
    }
    
}
