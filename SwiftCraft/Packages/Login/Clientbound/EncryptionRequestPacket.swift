//
//  EncryptionRequest.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

struct EncryptionRequestPacket: HandleablePacket {
    static var packetID = PacketID(connectionState: .login, id: 0x01)

    let serverID: String
    let publicKey: ByteArray
    let verifyToken: ByteArray

    init<Buffer: ReadBuffer>(from buffer: Buffer) throws where Buffer.Element == Byte {
        serverID = try String(from: buffer)

        let publicKeyLength = try VarInt32(from: buffer)
        publicKey = try buffer.read(lenght: Int(publicKeyLength.value))

        let verifyTokenLength = try VarInt32(from: buffer)
        verifyToken = try buffer.read(lenght: Int(verifyTokenLength.value))
    }

    func handle(with client: MinecraftClient) throws {
        try client.receivedEncryptionRequestPacket(self)
    }
}

extension MinecraftClient {
    func receivedEncryptionRequestPacket(_ packet: EncryptionRequestPacket) throws {
        guard let serverIDData = packet.serverID.data(using: .ascii) else {
            throw EncryptionRequestPacketError.invalidServerID
        }

        let publicKeyData = Data(bytes: packet.publicKey)
        let sharedSecret = generateSharedSecret()

        let encryptedVerifyToken = try encrypt(Data(bytes: packet.verifyToken), withKey: publicKeyData)
        let encryptedSharedSecret = try encrypt(sharedSecret, withKey: publicKeyData)

        let serverHash = sessionServerService.serverHash(
            serverID: serverIDData,
            sharedSecret: sharedSecret,
            publicKey: publicKeyData)

        let responsePacket = EncryptionResponsePacket(
            encryptedSharedSecret: Array(encryptedSharedSecret),
            encryptedVerifyToken: Array(encryptedVerifyToken))

        sessionServerService.joinSessionRequest(serverHash: serverHash).startWithResult { [weak self] _ in
            self?.sendPacket(responsePacket)
            self?.enableEncryption(sharedSecret: sharedSecret)
        }
    }

    private func encrypt(_ data: Data, withKey keyData: Data) throws -> Data {
        return try CC.RSA.encrypt(
            data,
            derKey: keyData,
            tag: Data(),
            padding: .pkcs1,
            digest: .none)
    }

    private func generateSharedSecret() -> Data {
        return CC.generateRandom(16)
    }
}

enum EncryptionRequestPacketError: Error {
    case invalidServerID
}
