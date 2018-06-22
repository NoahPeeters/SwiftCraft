//
//  CrypoWrapper.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 22.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

#if !SWCRYPT
    import Crypto
#endif

public enum CryptoWrapper {
    public static func sha1Hash(_ data: Data) throws -> Data {
        #if SWCRYPT
        return CC.digest(data, alg: .sha1)
        #else
        return try SHA1.hash(data)
        #endif
    }

    public static func generateRandomData(count: Int) throws -> Data {
        #if SWCRYPT
        return CC.generateRandom(count)
        #else
        return try CryptoRandom().generateData(count: 16)
        #endif
    }

    /// Encrptes data with rsa.
    ///
    /// - Parameters:
    ///   - data: The data to encrypt.
    ///   - keyData: The public key.
    /// - Returns: The encrypted data.
    /// - Throws: An encryption error.
    public static func encrypt(_ data: Data, withPublicKey keyData: Data) throws -> Data {
        #if SWCRYPT
        return try CC.RSA.encrypt(
            data,
            derKey: keyData,
            tag: Data(),
            padding: .pkcs1,
            digest: .none)
        #else
        let pemString = """
        -----BEGIN PUBLIC KEY-----
        \(keyData.base64EncodedString())
        -----END PUBLIC KEY-----
        """

        let key = try RSAKey.public(pem: pemString)
        return try RSA.encrypt(data, padding: .pkcs1, key: key)
        #endif
    }
}
