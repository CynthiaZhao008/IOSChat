//
//  ChatViewController.swift
//  WebSockets

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate{
    
    var Model : IOSModel = IOSModel()
    var userList : UserListViewController = UserListViewController()
    private var keyboard : Keyboard = Keyboard()
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
        messageTextField.delegate = self
        self.setupKeyboardScrolling()
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageTextField: UITextField!
    @IBOutlet private weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollToBottom(animated: false)
    }

    func apply(username: String) {
        self.username = username
    }
    
    func changeFormat(currTime: String) -> String{
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //done
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
            self?.scrollToBottom(animated: true)
        })
        
    }
    
    private func setupKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: keyboardWillShow)
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil, using: keyboardWillHide)
    }
    
    private func setupKeyboardScrolling() {
        self.keyboard = Keyboard()
        let keyboardAnimation = { [unowned self] in
            self.bottomViewHeightConstraint.constant = self.keyboard.height
            self.view.layoutIfNeeded()
        }
        let keyboardCompletion: (Bool) -> Void = { [unowned self] _ in
            self.scrollToBottom(animated: true)
        }
        self.keyboard.heightChanged = {
            UIView.animate(
                withDuration: 0.2,
                animations: keyboardAnimation,
                completion: keyboardCompletion
            )
        }
        let tap =
            UITapGestureRecognizer(
                target: self,
                action: #selector(self.hideKeyboard(_:))
            )
        self.tableView.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard(_ sender: UITapGestureRecognizer) {
        self.messageTextField.resignFirstResponder()
    }
    
    
    @objc
    private func keyboardWillShow(with notification: Notification) {
        guard let info = notification.userInfo, let keyboardEndSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        let keyboardHeight = keyboardEndSize.height 
        let lastVisibleCell = tableView.indexPathsForVisibleRows?.last

        UIView.animate(withDuration:0.3, delay: 0, options: [.curveEaseInOut], animations: { [self] in
            self.bottomViewHeightConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
            if let lastVisibleCell = lastVisibleCell{
                self.tableView.scrollToRow(at: lastVisibleCell, at: .bottom, animated: true)
            }
        })
    }
    
    private func scrollToBottom(animated: Bool){
        if messages.count > 0{
        let lastRow = IndexPath(row: messages.count-1, section: 0)
        self.tableView.scrollToRow(at: lastRow, at: .bottom, animated: animated)
        }
    }

    @objc
    private func keyboardWillHide(with notification: Notification) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.bottomViewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
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
    
    func configure(message: String, username: String, timeSent: String){
        messageLabel.text = message
        senderLabel.text = "\(username)"
        timeSentLabel.text = timeSent
        
    }
    
}
