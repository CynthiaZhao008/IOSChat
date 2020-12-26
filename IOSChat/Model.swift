//
//  Model.swift
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

