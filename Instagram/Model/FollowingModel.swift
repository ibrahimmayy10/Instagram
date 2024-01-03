//
//  FollowingModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 20.12.2023.
//

import Foundation

struct FollowingModel {
    let name: String
    let imageUrl: String
    let postedBy: String
    
    init(name: String, imageUrl: String, postedBy: String) {
        self.name = name
        self.imageUrl = imageUrl
        self.postedBy = postedBy
    }
}
