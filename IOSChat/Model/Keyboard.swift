
import UIKit

private let LOG_TAG = "Keyboard"

enum KeyboardState {
    case None
    case Shown
    case Hidden
}

typealias KeyboardCallback = () -> Void
class Keyboard : NSObject {
    override init() {
        super.init()
        // Track height.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Keyboard.keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Keyboard.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        // Track state.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Keyboard.keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Keyboard.keyboardDidHide(notification:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    var state = KeyboardState.None
    var stateChanged: KeyboardCallback? = nil

    @objc func keyboardDidHide(notification: Notification) {
        self.state = .Hidden
        if let callback = self.stateChanged {
            callback()
        }
    }

    @objc func keyboardDidShow(notification: Notification) {
        self.state = .Shown
        if let callback = self.stateChanged {
            callback()
        }
    }
    var height: CGFloat = 0
    var heightChanged: KeyboardCallback? = nil
    
    @objc func keyboardWillHide(notification: Notification) {
        NSLog("\(LOG_TAG) will hide")
        self.height = 0
        NSLog("\(LOG_TAG) keyboard height: '\(height)'")
        if let callback = self.heightChanged {
            callback()
        }
    }

    @objc func keyboardWillShow(notification: Notification) {
        NSLog("\(LOG_TAG) will show")
        let frameEnd =
            notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        self.height = frameEnd.cgRectValue.height
        NSLog("\(LOG_TAG) keyboard height: '\(self.height)'")
        if let callback = self.heightChanged {
            callback()
        }
    }

    private func printFrame(_ notification: Notification) {
        let frameBegin =
            notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let frameEnd =
            notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        NSLog("\(LOG_TAG) frame begin: '\(frameBegin)' frame end: '\(frameEnd)'")
    }

}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func clearTextField(_ textField: UITextField){
        textField.text = ""
    }
    
    func TextFieldChars(_ textField: UITextField) -> Bool{
        if textField.text!.count > 0 {
            return true
        }
        return false
    }
    
    
}
