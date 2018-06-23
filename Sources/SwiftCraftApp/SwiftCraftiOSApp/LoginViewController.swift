//
//  LoginViewController.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 23.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import UIKit
import SwiftCraft

public class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet public weak var hostTextField: UITextField!
    @IBOutlet public weak var portTextField: UITextField!
    @IBOutlet public weak var usernameTextField: UITextField!
    @IBOutlet public weak var passwordTextField: UITextField!

    public override func viewDidLoad() {
        super.viewDidLoad()
        hostTextField.delegate = self
        portTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    @IBAction public func loginOffline(_ sender: Any) {
        startGame(sessionServer: OfflineSessionService(username: usernameTextField.text ?? ""))
    }

    @IBAction public func loginOnline(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        let loginService = UserLoginService()
        let credentials = UserLoginPasswordCredentials(username: username, password: password)
        loginService.login(credentials: credentials, requestUser: false) { response in
            DispatchQueue.main.async {
                if let response = response {
                    self.startGame(sessionServer: SessionServerService(authenticationProvider: response))
                } else {
                    self.presentAlert(title: "Login failed.", message: "Check username and password")
                }
            }
        }
    }

    private func startGame(sessionServer: SessionServerServiceProtocol) {
        guard let gameViewController = storyboard?
            .instantiateViewController(withIdentifier: "gameViewController") as? GameViewController else {
                return
        }

        gameViewController.start(
            host: hostTextField.text ?? "",
            port: portTextField.text.flatMap { Int($0) } ?? 25565,
            sessionServer: sessionServer)

        navigationController?.pushViewController(gameViewController, animated: true)
    }
}
