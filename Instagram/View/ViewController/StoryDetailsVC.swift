//
//  StoryDetailsVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 17.12.2023.
//

import UIKit
import SDWebImage

class StoryDetailsVC: UIViewController {
    
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    var storyImageUrl = String()
    var username = String()
    var userProfileImageUrl = String()
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.size.width / 2
        userProfileImageView.clipsToBounds = true
        
        write()
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(closeScreen), userInfo: nil, repeats: false)
        
    }
    
    @objc func closeScreen() {
        timer?.invalidate()
        navigationController?.popViewController(animated: false)
    }
    
    func write() {
        usernameLabel.text = username
        userProfileImageView.sd_setImage(with: URL(string: userProfileImageUrl))
        storyImageView.sd_setImage(with: URL(string: storyImageUrl))
    }

    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
}
