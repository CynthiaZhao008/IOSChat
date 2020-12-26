//
//  EnterViewController.swift
//  WebSockets

import UIKit

class EnterViewController: UIViewController {
    
    private enum Segues {
        static let showChat = "ShowChat"
    }
    
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var enterButton: UIButton!
    
    private var socketManager = Managers.socketManager

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        socketManager.establishConnection()
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == Segues.showChat {
            guard let username = sender as? String else {
                return
            }
            
            guard let destinationViewController = segue.destination as? UserListViewController else {
                return
            }
            
            destinationViewController.apply(username: username)
        }
        
    }

    @IBAction private func onEnterButtonTouchUpInside(_ sender: Any) {
        let username = userNameTextField.text
        
        self.performSegue(withIdentifier: Segues.showChat, sender: username)
    }
    
    private func setupView() {
        enterButton.layer.cornerRadius = 5
    }
}
