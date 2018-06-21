//
//  ContinuousMessageCryptor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import SwiftCraftAES

/// Handels the de- and encryption of an incomming and an outgoing stream of data.
public class ContinuousMessageCryptor {
    /// The `AESCipher` used for encryption of outgoing messages.
    private let encryptor: AESCipher

    /// The `AESCipher` used for decryption of incomming messages.
    private let decryptor: AESCipher

    /// Creates a new `ContinuousMessageCryptor` with a given shared secret.
    ///
    /// - Parameter sharedSecret: The shared secret will be used for both the key and the iv.
    public init(sharedSecret: Data) {
        encryptor = AESCipher(mode: MODE_CFB, keyData: sharedSecret, ivData: sharedSecret)
        decryptor = AESCipher(mode: MODE_CFB, keyData: sharedSecret, ivData: sharedSecret)
    }

    /// Encryptes a message for sending.
    ///
    /// - Parameter plainData: The plaintext data.
    /// - Returns: The encrypted data.
    public func encryptOutgoingMessage(_ plainData: Data) -> Data {
        return encryptor.encrypt(plainData)
    }

    /// Decryptes a received message.
    ///
    /// - Parameter cipherData: The cipher data to decrypt.
    /// - Returns: The plaintext data.
    public func decryptIncommingMessage(_ cipherData: Data) -> Data {
        return decryptor.decrypt(cipherData)
    }
}
