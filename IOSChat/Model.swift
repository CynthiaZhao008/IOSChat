//
//  Model.swift
//  
//
//  Created by user182051 on 12/26/20.
//

import Foundation

enum Status {
    case online
    case offline
    
}

struct UserData {
    let username: String
    let status: Status
}

struct MessageData {
    let text: String
    let sender: String
}

