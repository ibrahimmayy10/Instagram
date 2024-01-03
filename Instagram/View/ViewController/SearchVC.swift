//
//  SearchVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 15.10.2023.
//

import UIKit
import Firebase
import MobileCoreServices

class SearchVC: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var users: [UserModel] = []
    var filteredUsers: [UserModel] = []
    
    var isStorySelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Ara...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        searchUser()
        
    }
    
    @objc func searchTextChanged () {
        filtersUser(searchText: searchTextField
            .text ?? "")
    }
    
    func searchUser () {
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("users").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                for document in snapshot!.documents {
                    if let name = document.get("name") as? String, let username = document.get("username") as? String, let imageUrl = document.get("imageUrl") as? String, let postedBy = document.get("postedBy") as? String {
                        let users = UserModel(name: name, username: username, imageUrl: imageUrl, postedBy: postedBy)
                        self.users.append(users)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func filtersUser (searchText: String) {
        if searchText.isEmpty {
            filteredUsers = []
        } else {
            let filteredUsers = users.filter { user in
                let usernameMatch = user.username.lowercased().contains(searchText.lowercased())
                let nameMatch = user.name.lowercased().contains(searchText.lowercased())
                return usernameMatch || nameMatch
            }
            self.filteredUsers = filteredUsers
        }
        self.tableView.reloadData()
    }
    
    @IBAction func homePageButton(_ sender: Any) {
        let homeVC = storyboard?.instantiateViewController(identifier: "toHomePageVC") as! HomePageVC
        navigationController?.pushViewController(homeVC, animated: false)
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
    
    @IBAction func accountButton(_ sender: Any) {
        let accountVC = storyboard?.instantiateViewController(identifier: "toAccountVC") as! AccountVC
        navigationController?.pushViewController(accountVC, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchUserTableViewCell
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = selectedView
        
        let search = filteredUsers[indexPath.row]
        cell.searchUsernameLabel.text = search.username
        cell.searchNameLabel.text = search.name
        
        cell.searchImageView.layer.cornerRadius = cell.searchImageView.layer.frame.width / 2
        cell.searchImageView.clipsToBounds = true
        cell.searchImageView.sd_setImage(with: URL(string: search.imageUrl))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let search = filteredUsers[indexPath.row]
        let userDetailsVC = storyboard?.instantiateViewController(identifier: "toUserDetailsVC") as! UserDetailsVC
        userDetailsVC.username = search.username
        userDetailsVC.selectedImage = search.imageUrl
        userDetailsVC.postedBy = search.postedBy
        userDetailsVC.name = search.name
        navigationController?.pushViewController(userDetailsVC, animated: true)
    }
    
}
