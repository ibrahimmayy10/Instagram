//
//  PostShareVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 15.10.2023.
//

import UIKit

class PostShareVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
    }
    
    @IBAction func homePageButton(_ sender: Any) {
        let homeVC = storyboard?.instantiateViewController(identifier: "toHomePageVC") as! HomePageVC
        navigationController?.pushViewController(homeVC, animated: false)
    }
    
    @IBAction func searchButton(_ sender: Any) {
        let searchVC = storyboard?.instantiateViewController(identifier: "toSearchVC") as! SearchVC
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    @IBAction func reelsButton(_ sender: Any) {
        let reelsVC = storyboard?.instantiateViewController(identifier: "toReelsVC") as! ReelsVC
        navigationController?.pushViewController(reelsVC, animated: false)
    }
    
    @IBAction func accountButton(_ sender: Any) {
        let accountVC = storyboard?.instantiateViewController(identifier: "toAccountVC") as! AccountVC
        navigationController?.pushViewController(accountVC, animated: false)
    }
    
}
