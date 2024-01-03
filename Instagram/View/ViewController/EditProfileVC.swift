//
//  EditProfileVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 19.12.2023.
//

import UIKit
import Firebase
import SDWebImage

class EditProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var sections = ["Adı", "Kullanıcı adı", "Biyografi"]
    var results = [String]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        getDataUserInfo()
        
    }
    
    func getDataUserInfo() {
        let firestore = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        firestore.collection("users").whereField("postedBy", isEqualTo: currentUserID).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    guard let imageUrl = document.get("imageUrl") as? String,
                          let username = document.get("username") as? String,
                          let name = document.get("name") as? String,
                          let biography = document.get("biography") as? String  else { return }
                    self.imageView.sd_setImage(with: URL(string: imageUrl))
                    self.results.append(name)
                    self.results.append(username)
                    self.results.append(biography)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as! EditProfileTableViewCell
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = selectedView
        
        let section = sections[indexPath.row]
        let result = results[indexPath.row]
        cell.sectionLabel.text = section
        cell.resultLabel.text = result
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.row]
        let result = results[indexPath.row]
        
        let changeInfoVC = storyboard?.instantiateViewController(identifier: "toChangeInfoVC") as! ChangeInfoVC
        changeInfoVC.result = result
        changeInfoVC.section = section
        navigationController?.pushViewController(changeInfoVC, animated: true)
    }
    
}
