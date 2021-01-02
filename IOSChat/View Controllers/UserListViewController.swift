//
//  UserListViewController.swift
//  WebSockets


import UIKit
//import Model

class UserListViewController: UIViewController, UITextFieldDelegate {
    
    var Model : IOSModel = IOSModel()
    private var socketManager = Managers.socketManager
    private var username: String!
    private var users: [UserData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        connectToChat()
        startObservingUserList()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBAction private func onWriteMessageTouchUpInside(_ sender: Any) {
        self.performSegue(withIdentifier: Segues.writeMessage, sender: self.username)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Segues.writeMessage {
            guard let username = sender as? String else {
                return
            }
            guard let controller = segue.destination as? ChatViewController else {
                return
            }
            controller.apply(username: username)
        }
    }
    
    func apply(username: String) {
        self.username = username
    }
    
    private func connectToChat() {
        socketManager.connectToChat(with: self.username)
    }
    
    private func startObservingUserList() {
        socketManager.observeUserList(completionHandler: { [weak self] data in
            var currentUsers: [UserData] = []
            for userData in data {
                let name = userData["nickname"] as! String
                let isConnected = userData["isConnected"] as! Bool
                let user = UserData(username: name, status: isConnected ? .online : .offline)
                currentUsers.append(user)
            }
            self?.users = currentUsers
        })
    }
    
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.userTableCell, for: indexPath) as! UserTableViewCell
        cell.configure(userName: user.username, status: user.status)
        return cell
    }
}

class UserTableViewCell: UITableViewCell {
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    
    func configure(userName: String, status: Status) {
        userNameLabel.text = userName
        switch status {
        case .online:
            statusLabel.text = "Online"
            statusLabel.textColor = .green
        case .offline:
            statusLabel.text = "Offline"
            statusLabel.textColor = .red
        }
    }
}
