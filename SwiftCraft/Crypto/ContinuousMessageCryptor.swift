//
//  ContinuousMessageCryptor.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public class ContinuousMessageCryptor {
    private let encryptor: AESCipher
    private let decryptor: AESCipher

    public init(sharedSecret: Data) {
        encryptor = AESCipher(mode: MODE_CFB, keyData: sharedSecret, ivData: sharedSecret)
        decryptor = AESCipher(mode: MODE_CFB, keyData: sharedSecret, ivData: sharedSecret)
    }

    public func encryptOutgoingMessage(_ plainData: Data) -> Data {
        return encryptor.encrypt(plainData)
    }

    public func decryptIncommingMessage(_ cipherData: Data) -> Data {
        return decryptor.decrypt(cipherData)
    }
}
