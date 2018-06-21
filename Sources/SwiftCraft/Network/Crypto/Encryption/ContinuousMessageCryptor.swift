//
//  ContinuousMessageCryptor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
import CryptoSwift

/// Handels the de- and encryption of an incomming and an outgoing stream of data.
public class ContinuousMessageCryptor {
    /// The `AESCipher` used for encryption of outgoing messages.
    private var encryptor: AES.Encryptor

    /// The `AESCipher` used for decryption of incomming messages.
    private var decryptor: AES.Decryptor

    /// Creates a new `ContinuousMessageCryptor` with a given shared secret.
    ///
    /// - Parameter sharedSecret: The shared secret will be used for both the key and the iv.
    public init(sharedSecret: Data) throws {
        let key = Array(sharedSecret)
        let aes = try AES(key: key, blockMode: CFB(iv: key), padding: .noPadding)
        encryptor = try aes.makeEncryptor()
        decryptor = try aes.makeDecryptor()
    }

    /// Encryptes a message for sending.
    ///
    /// - Parameter plainData: The plaintext data.
    /// - Returns: The encrypted data.
    public func encryptOutgoingMessage(_ plainData: ByteArray) throws -> ByteArray {
        return try encryptor.update(withBytes: plainData)
    }

    /// Decryptes a received message.
    ///
    /// - Parameter cipherData: The cipher data to decrypt.
    /// - Returns: The plaintext data.
    public func decryptIncommingMessage(_ cipherData: ByteArray) throws -> ByteArray {
        return try decryptor.update(withBytes: cipherData)
    }
}
