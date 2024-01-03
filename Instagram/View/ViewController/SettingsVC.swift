//
//  SettingsVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 15.10.2023.
//

import UIKit
import Firebase

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var choices = ["Yorumlar", "Beğeniler", "Gönderiler", "Çıkış yap"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableViewCell
        
        let selectedView = UIView()
        selectedView.backgroundColor = .darkGray
        cell.selectedBackgroundView = selectedView
        
        let choice = choices[indexPath.row]
        if choice == "Çıkış yap" {
            cell.choiceLabel.textColor = .red
            cell.choiceLabel.text = choice
        } else {
            cell.choiceLabel.text = choice
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let choice = choices[indexPath.row]
        
        if choice == "Çıkış yap" {
            do {
                try Auth.auth().signOut()
                let toVC = storyboard?.instantiateViewController(identifier: "toVC") as! ViewController
                navigationController?.pushViewController(toVC, animated: true)
            } catch {
                print("çıkış yapılamadı")
            }
        } else {
            let accountVC = storyboard?.instantiateViewController(identifier: "toAccountVC") as! AccountVC
            navigationController?.pushViewController(accountVC, animated: true)
        }
    }
    
}
