//
//  ViewController.swift
//  Instagram
//
//  Created by İbrahim Ay on 14.10.2023.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        let currentUser = Auth.auth().currentUser
        
        if currentUser != nil {
            let homePageVC = storyboard?.instantiateViewController(identifier: "toHomePageVC") as! HomePageVC
            navigationController?.pushViewController(homePageVC, animated: true)
        }

    }

    @IBAction func signButton(_ sender: Any) {
        let email = usernameTextField.text
        let password = passwordTextField.text
        
        if email != nil || password != nil {
            Auth.auth().signIn(withEmail: email ?? "", password: password ?? "") { authdata, error in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    let homePageVC = self.storyboard?.instantiateViewController(identifier: "toHomePageVC") as! HomePageVC
                    self.navigationController?.pushViewController(homePageVC, animated: true)
                }
            }
        }
    }
    
    func makeAlert (messageInput: String) {
        let alert = UIAlertController(title: "", message: messageInput, preferredStyle: .alert)
        let okButton = alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let registerVC = storyboard?.instantiateViewController(identifier: "toRegisterVC") as! RegisterVC
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
}

