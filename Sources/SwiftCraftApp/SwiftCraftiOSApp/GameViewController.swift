//
//  GameViewController.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 23.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import UIKit
import SwiftCraft

public class GameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet public weak var messageTextField: UITextField!

    private var client: MinecraftClient!
    private var messages: [String] = []

    public func start(host: String, port: Int, sessionServer: SessionServerServiceProtocol) {
        client = MinecraftClient(
            tcpClient: TCPClient(
                host: host,
                port: port),
            packetLibrary: DefaultPacketLibrary(),
            sessionServerService: sessionServer)

        _ = client.addReactor(MinecraftClient.essentialReactors())
        _ = client.addReactor(ClosureReactor<ReceiveChatMessagePacket> { [weak self] packet, _ in
            self?.addMessage(packet.message.message.string)
        })

        client.onOpen { [weak self] in
            DispatchQueue.main.async {
                self?.addMessage("Connection opened")
            }
        }

        client.onClose { [weak self] connectionState in
            DispatchQueue.main.async {
                self?.addMessage("Connection closed \(connectionState)")
            }
        }

        _ = client.connectAndLogin()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        messageTextField.delegate = self
    }

    public func addMessage(_ message: String) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView?.insertRows(at: [indexPath], with: .automatic)
        tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    @IBAction public func sendMessage() {
        let message = messageTextField.text ?? ""
        messageTextField.resignFirstResponder()

        if !message.isEmpty {
            client.sendMessage(message)
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return false
    }
}

extension GameViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }
}
