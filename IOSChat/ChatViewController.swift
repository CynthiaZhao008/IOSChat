//
//  ChatViewController.swift
//  WebSockets

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate {
    
    private enum Identifiers {
        static let messageTableCell = "MessageTableCell"
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageTextField: UITextField!
    @IBOutlet private weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    private var username: String!
    
    private var socketManager = Managers.socketManager
    
    private var messages: [MessageData] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardNotifications()
        
        self.navigationItem.title = username
        
        startObservingMessages()
        
       // self.hideKeyboardWhenTappedAround()
        
        messageTextField.delegate = self
        
    }

    func apply(username: String) {
        self.username = username
    }
    
    func changeFormat(currTime: String) -> String
    {
        let formatter = DateFormatter()
        
        //input format
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let date = formatter.date(from: currTime)!
        
        //output format
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let formattedTime = formatter.string(from: date)
        return formattedTime
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
       
    
    @IBAction func onSendButtonTouchUpInside(_ sender: UIButton) {
        guard TextFieldChars(messageTextField) != false else{
            let myAlert = UIAlertController(title: "Invalid", message: "Please enter a message", preferredStyle: UIAlertController.Style.alert)
            myAlert.addAction(UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(myAlert, animated:true, completion: nil)
                return
        }
        let text = messageTextField.text ?? ""
        socketManager.send(message: text, username: self.username)
        clearTextField(messageTextField)
    }
    
    func startObservingMessages() {
        socketManager.observeMessages(completionHandler: { [weak self] data in
            let name = data["nickname"] as! String
            let text = data["message"] as! String
            let time = data["timeSent"] as! String
            
            let message = MessageData(text: text, sender: name, time: time)
            
            self?.messages.append(message)
        })
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(with:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(with:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc
    private func keyboardWillShow(with notification: Notification) {
        guard let info = notification.userInfo, let keyboardEndSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        
        let keyboardHeight = keyboardEndSize.height
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.bottomViewHeightConstraint.constant = keyboardHeight
            
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillHide(with notification: Notification) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.bottomViewHeightConstraint.constant = 0
            
            self?.view.layoutIfNeeded()
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.messageTableCell, for: indexPath) as! MessageTableViewCell
        
        cell.configure(message: message.text, username: message.sender, timeSent: changeFormat(currTime: message.time))
        
        return cell
    }
}

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var timeSentLabel: UILabel!
    
    func configure(message: String, username: String, timeSent: String) {
        
        messageLabel.text = message
        senderLabel.text = "\(username)"
        timeSentLabel.text = timeSent
    }
}
