//
//  ReelsVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 15.10.2023.
//

import UIKit
import MobileCoreServices
import Firebase

class ReelsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ReelsTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var videoUrl = [String]()
    var explanationArray = [String]()
    var usernameArray = [String]()
    var imageUrlArray = [String]()
    
    var reelsModel = [ReelsModel]()
    
    var currentPlayingCell: ReelsTableViewCell?
    
    var isStorySelected = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isPagingEnabled = true
        
        getDataReels()
                    
    }
    
    func sendReelsButton(at cell: ReelsTableViewCell) {
        for cell in tableView.visibleCells {
            if let cell = cell as? ReelsTableViewCell {
                cell.player?.pause()
            }
        }
        if let indexPath = tableView.indexPath(for: cell) {
            let reels = reelsModel[indexPath.row]
            let sendReelsVC = self.storyboard?.instantiateViewController(identifier: "toSendReelsVC") as! SendReelsVC
            sendReelsVC.videoUrl = reels.videoUrl
            present(sendReelsVC, animated: true)
        }
    }
    
    func didTapReelsCommentButton(at cell: ReelsTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let reels = reelsModel[indexPath.row]
            let reelsCommentVC = self.storyboard?.instantiateViewController(withIdentifier: "toReelsCommentVC") as! ReelsCommentVC
            reelsCommentVC.reelsId = reels.reelsId
            present(reelsCommentVC, animated: true)
        }
    }
    
    func getDataReels () {
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Reels").addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("belge bulunamadı")
                return
            }
            
            self.videoUrl.removeAll()
            self.explanationArray.removeAll()
            
            for document in documents {
                if let videoUrl = document.get("videoUrl") as? String, let explanation = document.get("explanation") as? String, let postedBy = document.get("postedBy") as? String, let reelsId = document.get("reelsId") as? String {
                    firestoreDatabase.collection("users").document(postedBy).getDocument { documents, error in
                        if let username = documents?.get("username") as? String, let imageUrl = documents?.get("imageUrl") as? String {
                            
                            guard let documents = snapshot?.documents else { return }
                            
                            let reels = documents.compactMap { document in
                                return ReelsModel.createFrom(document.data())
                            }
                            
                            self.reelsModel = reels
                            self.usernameArray.append(username)
                            self.imageUrlArray.append(imageUrl)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func homePageButton(_ sender: Any) {
        for cell in tableView.visibleCells {
            if let cell = cell as? ReelsTableViewCell {
                cell.player?.pause()
            }
        }
        
        let homeVC = storyboard?.instantiateViewController(identifier: "toHomePageVC") as! HomePageVC
        navigationController?.pushViewController(homeVC, animated: false)
    }
    
    @IBAction func searchButton(_ sender: Any) {
        for cell in tableView.visibleCells {
            if let cell = cell as? ReelsTableViewCell {
                cell.player?.pause()
            }
        }
        
        let searchVC = storyboard?.instantiateViewController(identifier: "toSearchVC") as! SearchVC
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    @IBAction func addPostButton(_ sender: Any) {
        for cell in tableView.visibleCells {
            if let cell = cell as? ReelsTableViewCell {
                cell.player?.pause()
            }
        }
        
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
    
    @IBAction func accountButton(_ sender: Any) {
        for cell in tableView.visibleCells {
            if let cell = cell as? ReelsTableViewCell {
                cell.player?.pause()
            }
        }
        
        let accountVC = storyboard?.instantiateViewController(identifier: "toAccountVC") as! AccountVC
        navigationController?.pushViewController(accountVC, animated: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pauseNonVisibleVideos()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pauseNonVisibleVideos()
        }
    }
    
    func pauseNonVisibleVideos () {
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                if let cell = cell as? ReelsTableViewCell {
                    cell.player?.play()
                    currentPlayingCell = cell
                }
            } else {
                if let cell = cell as? ReelsTableViewCell {
                    cell.player?.pause()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reelsModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reelsCell", for: indexPath) as! ReelsTableViewCell
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = selectedView
        
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
        cell.profileImageView.clipsToBounds = true
        
        let reels = reelsModel[indexPath.row]
        
        cell.reelsExplanationLabel.text = reels.explanation
        cell.reelsUsernameLabel.text = usernameArray[indexPath.row]
        cell.profileImageView.sd_setImage(with: URL(string: imageUrlArray[indexPath.row]))
        
        cell.reelsId = reels.reelsId
        
        cell.delegate = self
        
        cell.overlayView.layer.zPosition = 1
        cell.likeBtn.layer.zPosition = 1
        cell.likeLabel.layer.zPosition = 1
        cell.commentBtn.layer.zPosition = 1
        cell.sendBtn.layer.zPosition = 1
        cell.commentCountLabel.layer.zPosition = 1
        
        cell.contentView.bringSubviewToFront(cell.overlayView)
        cell.overlayView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        
        cell.configure(with: reels.videoUrl)
        
        let firestoreDatabase = Firestore.firestore()
        
        let user = Auth.auth().currentUser
        let currentUserID = user?.uid
        
        firestoreDatabase.collection("ReelsLikes").whereField("reelsId", isEqualTo: reels.reelsId).getDocuments { documents, error in
            if error != nil {
                print("HATA: \(error?.localizedDescription ?? "")")
            } else if let document = documents?.documents {
                cell.likeLabel.text = String(document.count)
                
                cell.likeBtn.setImage(document.contains { $0["postedBy"] as? String == currentUserID } ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)
                cell.likeBtn.tintColor = document.contains { $0["postedBy"] as? String == currentUserID } ? .red : .white
                cell.likeBtn.tag = document.contains { $0["postedBy"] as? String == currentUserID } ? 1 : 0
            }
        }
        
        firestoreDatabase.collection("ReelsComments").whereField("reelsId", isEqualTo: reels.reelsId).getDocuments { snapshot, error in
            if error != nil {
                print("HATA: \(error?.localizedDescription ?? "")")
            } else if let documents = snapshot?.documents {
                cell.commentCountLabel.text = String(documents.count)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ReelsTableViewCell {
            cell.player?.play()
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ReelsTableViewCell {
            cell.player?.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 713
    }

}
