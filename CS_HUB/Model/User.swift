//
//  User.swift
//  CS_HUB
//
//  Created by Nikstanov on 19.03.24.
//

import Foundation

struct User : Hashable, Codable{
    let id: String
    let email: String
    let firstname: String
    let lastname: String
    let country: String
}
