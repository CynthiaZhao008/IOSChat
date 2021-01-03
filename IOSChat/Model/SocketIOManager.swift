//
//  SocketIOManager.swift
//  
import UIKit
import SocketIO

protocol SocketIOManager {
    
    func establishConnection()
    func closeConnection()
    func connectToChat(with name: String)
    func observeUserList(completionHandler: @escaping ([[String: Any]]) -> Void)
    func send(message: String, username: String)
    func observeMessages(completionHandler: @escaping ([String: Any]) -> Void)
    
}

enum Managers {
    static let socketManager: SocketIOManager = SocketIOManagerDefault()
}

class SocketIOManagerDefault: NSObject, SocketIOManager {
    
    private var manager: SocketManager!
    private var socket: SocketIOClient!

    
    override init() {
        super.init()
        
        manager = SocketManager(socketURL: URL(string: "http://74.91.11.107:3000")!)
        //manager = SocketManager(socketURL: URL(string: "http://192.168.1.31:3000")!)
        socket = manager.defaultSocket
    }

    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToChat(with name: String) {
        socket.emit("connectUser", name)
    }
    
    func observeUserList(completionHandler: @escaping ([[String: Any]]) -> Void) {
        socket.on("userList") { dataArray, _ in
            completionHandler(dataArray[0] as! [[String: Any]])
        }
    }
    
    func send(message: String, username: String){
        socket.emit("chatMessage", username, message)
    }
    
    func observeMessages(completionHandler: @escaping ([String: Any]) -> Void) {
        socket.on("newChatMessage") { dataArray, _ in
            var messageDict: [String: Any] = [:]
            
            messageDict["nickname"] = dataArray[0] as! String
            messageDict["message"] = dataArray[1] as! String
            messageDict["timeSent"] = dataArray[2] as! String
            
            completionHandler(messageDict)
        }
    }
}
