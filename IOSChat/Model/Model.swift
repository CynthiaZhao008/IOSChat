//
//  Model.swift
//  


import Foundation
import UIKit

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
    let time: String
}

enum Segues {
    static let writeMessage = "WriteMessage"
    static let showChat = "ShowChat"
}

enum Identifiers {
    static let userTableCell = "UserTableCell"
    static let messageTableCell = "MessageTableCell"
    
}
/*
private enum Identifiers {
    
}
 
 private enum Segues {
     
 }
*/
class IOSModel {
    

}


