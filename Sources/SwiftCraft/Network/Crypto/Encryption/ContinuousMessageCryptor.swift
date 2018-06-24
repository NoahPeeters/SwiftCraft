//
//  ContinuousMessageCryptor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

/// Handels the de- and encryption of an incomming and an outgoing stream of data.
public class ContinuousMessageCryptor {
    #if MESSAGE_ENCRYPTION
    /// The `AESCipher` used for encryption of outgoing messages.
    private let encryptor: AESCipher

    /// The `AESCipher` used for decryption of incomming messages.
    private let decryptor: AESCipher
    #endif

    /// Creates a new `ContinuousMessageCryptor` with a given shared secret.
    ///
    /// - Parameter sharedSecret: The shared secret will be used for both the key and the iv.
    public init(sharedSecret: Data) {
        #if MESSAGE_ENCRYPTION
        encryptor = AESCipher(mode: MODE_CFB, keyData: sharedSecret, ivData: sharedSecret)
        decryptor = AESCipher(mode: MODE_CFB, keyData: sharedSecret, ivData: sharedSecret)
        #endif
    }

    /// Encryptes a message for sending.
    ///
    /// - Parameter plainData: The plaintext data.
    /// - Returns: The encrypted data.
    public func encryptOutgoingMessage(_ plainData: Data) -> Data {
        #if MESSAGE_ENCRYPTION
        return encryptor.encrypt(plainData)
        #else
        return plainData
        #endif
    }

    /// Decryptes a received message.
    ///
    /// - Parameter cipherData: The cipher data to decrypt.
    /// - Returns: The plaintext data.
    public func decryptIncommingMessage(_ cipherData: Data) -> Data {
        #if MESSAGE_ENCRYPTION
        return decryptor.decrypt(cipherData)
        #else
        return cipherData
        #endif
    }
}
