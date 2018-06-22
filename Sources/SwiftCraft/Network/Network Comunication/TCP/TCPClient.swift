//
//  TCPClient.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation
#if os(Linux)
import Glibc
import COperatingSystem

// fix some constants on linux
let SOCK_STREAM = Int32(COperatingSystem.SOCK_STREAM.rawValue)
let IPPROTO_TCP = Int32(COperatingSystem.IPPROTO_TCP)
#else
import Darwin
#endif

/// Events of a TCPClient.
public enum TCPClientEvent: Hashable {
    /// The output stream has opened.
    case outputStreamOpened

    /// The input stream has opened.
    case inputStreamOpened

    /// The output stream has space available.
    case outputStreamHasSpaceAvailable

    /// The input stream has space available.
    case inputStreamHasSpaceAvailable

    /// The input stream received new data.
    case received(data: Data)

    /// The output stream closed.
    case outputStreamClosed

    /// The input stream closed.
    case inputStreamClosed

    /// A unknown error occured.
    case unknownError
}

/// A protocol for a tcp client like object.
public protocol TCPClientProtocol {
    /// Connects the client to its server.
    func connect() throws

    /// Closes the connection
    func close()

    /// Sets the handler for events
    ///
    /// - Parameter handler: Handler for events.
    func events(handler: ((TCPClientEvent) -> Void)?)

    /// The host to connect to.
    var host: String { get }

    /// The port to connect to
    var port: Int { get }

    /// Sends the given bytes if the outout stream is open.
    ///
    /// - Parameter bytes: The bytes to send.
    func send(data: Data) throws
}

extension TCPClientProtocol {
    public func send(bytes: ByteArray) throws {
        try send(data: Data(bytes: bytes))
    }
}

/// A simple TCP client to send and receive tcp messages.
public class TCPClient: NSObject, TCPClientProtocol {
    /// The underlying input stream.
    private var sockID: Int32?

    /// The host to connect to.
    public let host: String

    /// The port to connect to
    public let port: Int

    /// Handler for events.
    public var eventsHandler: ((TCPClientEvent) -> Void)?

    /// The maximum buffer size.
    public var maxBufferSize: Int = 4096

    /// Creates a new tcp client.
    ///
    /// - Parameters:
    ///   - host: The host to connect to.
    ///   - port: The port to connect to.
    public init(host: String, port: Int) {
        self.host = host
        self.port = port

        super.init()
    }

    private func createSocket(host: String, port: String) -> Int32? {
        var hints = addrinfo()

        hints.ai_family = AF_INET
        hints.ai_socktype = SOCK_STREAM

        var remotes: UnsafeMutablePointer<addrinfo>?
        let remotesError = getaddrinfo(host, "\(port)", &hints, &remotes)

        guard remotesError == 0 else {
            return nil
        }

        defer {
            freeaddrinfo(remotes)
        }

        guard let firstRemote = remotes else {
            return nil
        }

        for address in sequence(first: firstRemote, next: { $0.pointee.ai_next }) {
            let socketID = socket(address.pointee.ai_family, address.pointee.ai_socktype, address.pointee.ai_protocol)
            guard socketID != -1 else {
                continue
            }

            #if os(Linux)
            let connectStatus = Glibc.connect(socketID, address.pointee.ai_addr, address.pointee.ai_addrlen)
            #else
            let connectStatus = Darwin.connect(socketID, address.pointee.ai_addr, address.pointee.ai_addrlen)
            #endif

            guard connectStatus != -1 else {
                continue
            }

            return socketID
        }

        return nil
    }

    /// Connects to the host and port of the client.
    public func connect() throws {
        self.sockID = createSocket(host: host, port: "\(port)")
        startReading()
    }

    private var hasReader: Bool = false

    private func startReading() {
        if hasReader {
            return
        }
        hasReader = true
        DispatchQueue.main.async { [weak self] in
            defer {
                self?.hasReader = false
            }
            while let unwrappedSelf = self, let sockID = self?.sockID {
                let readSize = unwrappedSelf.maxBufferSize
                let dataPointer = UnsafeMutableRawPointer.allocate(
                    byteCount: readSize,
                    alignment: MemoryLayout<Byte>.alignment)

                let readLength = recv(sockID, dataPointer, readSize, 0)
                guard readLength > 0 else {
                    return
                }

                let data = Data(bytes: dataPointer, count: readLength)
                unwrappedSelf.eventsHandler?(TCPClientEvent.received(data: data))
            }
        }
    }

    /// Closes the connection to the server.
    /// - Attention: The close function must be called on the same runloop as the connect function.
    public func close() {
        if let sockID = sockID {
            #if os(Linux)
            Glibc.close(sockID)
            #else
            Darwin.close(sockID)
            #endif
        }
    }


    /// Sends the given bytes if the outout stream is open.
    ///
    /// - Parameter bytes: The bytes to send.
    public func send(data: Data) {
        if let sockID = sockID {
            let dataCount = data.count
            data.withUnsafeBytes { (pointer: UnsafePointer<Byte>) in
                #if os(Linux)
                _ = Glibc.send(sockID, UnsafeRawPointer(pointer), dataCount, 0)
                #else
                _ = Darwin.send(sockID, UnsafeRawPointer(pointer), dataCount, 0)
                #endif
            }
        }
    }

    /// Sets the handler for all future events.
    ///
    /// - Parameter handler: The handler to use for future events.
    public func events(handler: ((TCPClientEvent) -> Void)?) {
        self.eventsHandler = handler
    }
}
