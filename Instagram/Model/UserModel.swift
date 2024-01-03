//
//  UserModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 16.10.2023.
//

import Foundation

struct UserModel {
    let name: String
    let username: String
    let imageUrl: String
    let postedBy: String
    
    init(name: String, username: String, imageUrl: String, postedBy: String) {
        self.name = name
        self.username = username
        self.imageUrl = imageUrl
        self.postedBy = postedBy
    }
}
