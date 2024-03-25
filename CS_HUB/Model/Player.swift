//
//  PlayerDocument.swift
//  CS_HUB
//
//  Created by Nikstanov on 14.03.24.
//

import Foundation

struct Player: Hashable, Codable, Identifiable{
    
    let id: Int
    let full_name:String
    let nick_name:String
    let birth_date:Date
    let team_name:String
    let nationality:String
}
