//
//  TCPClient.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

/// Events of a TCPClient.
///
/// - outputStreamOpened: The output stream has opened.
/// - inputStreamOpened: The input stream has opened.
/// - outputStreamHasSpaceAvailable: The output stream has space available.
/// - inputStreamHasSpaceAvailable: The input stream has space available.
/// - received: The input stream received new data.
/// - outputStreamClosed: The output stream closed.
/// - inputStreamClosed: The input stream closed.
public enum TCPClientEvent: Equatable, Hashable {
    case outputStreamOpened
    case inputStreamOpened
    case outputStreamHasSpaceAvailable
    case inputStreamHasSpaceAvailable
    case received(data: Data)
    case outputStreamClosed
    case inputStreamClosed
    case unknownError
}

/// A protocol for a tcp client like object.
public protocol TCPClientProtocol {
    /// Connects the client to its server.
    func connect()

    /// Closes the connection
    func close()

    /// Sets the handler for events
    ///
    /// - Parameter handler: Handler for events.
    func events(handler: ((TCPClientEvent) -> Void)?)

    /// The host to connect to.
    var host: CFString { get }

    /// The port to connect to
    var port: UInt32 { get }

    /// Sends the given bytes if the outout stream is open.
    ///
    /// - Parameter bytes: The bytes to send.
    func send(bytes: ByteArray)
}

public class TCPClient: NSObject, TCPClientProtocol {
    /// The underlying input stream.
    private var inputStream: InputStream?
    /// The underlying output stream.
    private var outputStream: OutputStream?

    /// The host to connect to.
    public let host: CFString

    /// The port to connect to
    public let port: UInt32

    /// Handler for events.
    public var eventsHandler: ((TCPClientEvent) -> Void)?

    /// The maximum buffer size.
    public var maxBufferSize: Int = 1024

    /// Creates a new tcp client.
    ///
    /// - Parameters:
    ///   - host: The host to connect to.
    ///   - port: The port to connect to.
    public init(host: CFString, port: UInt32) {
        self.host = host
        self.port = port

        super.init()
    }

    public convenience init(host: String, port: Int) {
        self.init(host: host as CFString, port: UInt32(port))
    }

    public func connect() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(nil, host, port, &readStream, &writeStream)

        // close streams
        inputStream?.close()
        outputStream?.close()

        // create new steams
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()

        // set delegates
        inputStream!.delegate = self
        outputStream!.delegate = self

        // schedule
        inputStream!.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream!.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)

        // open
        inputStream!.open()
        outputStream!.open()
    }

    public func close() {
        if let inputStream = inputStream {
            closeStream(inputStream)
        }

        if let outputStream = outputStream {
            closeStream(outputStream)
        }
    }

    private func closeStream(_ stream: Stream) {
        stream.close()
        stream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }

    /// Sends the given bytes if the outout stream is open.
    ///
    /// - Parameter bytes: The bytes to send.
    public func send(bytes: ByteArray) {
        outputStream?.write(UnsafePointer<UInt8>(bytes), maxLength: bytes.count)
    }

    public func events(handler: ((TCPClientEvent) -> Void)?) {
        self.eventsHandler = handler
    }
}

extension TCPClient: StreamDelegate {
    public func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            streamOpened(stream)
        case .hasSpaceAvailable:
            streamHasSpaceAvailable(stream)
        case .hasBytesAvailable:
            streamHasBytesAvailable(stream)
        case .errorOccurred:
            eventsHandler?(.unknownError)
        case .endEncountered:
            streamEndOccured(stream)
        default:
            break
        }
    }

    /// Handels the opening of a stream.
    ///
    /// - Parameter stream: The steram.
    private func streamOpened(_ stream: Stream) {
        if stream == inputStream {
            eventsHandler?(.inputStreamOpened)
        } else if stream == outputStream {
            eventsHandler?(.outputStreamOpened)
        }
    }

    private func streamHasSpaceAvailable(_ stream: Stream) {
        if stream == inputStream {
            eventsHandler?(.inputStreamHasSpaceAvailable)
        } else if stream == outputStream {
            eventsHandler?(.outputStreamHasSpaceAvailable)
        }
    }

    private func streamHasBytesAvailable(_ stream: Stream) {
        guard stream == inputStream else {
            return
        }

        guard let inputStream = inputStream else {
            return
        }

        var buffer = [UInt8](repeating: 0, count: self.maxBufferSize)
        var length: Int!

        while inputStream.hasBytesAvailable {
            length = inputStream.read(&buffer, maxLength: self.maxBufferSize)
            if length > 0 {
                let data = Data(bytes: &buffer, count: length)
                eventsHandler?(.received(data: data))
            }
        }
    }

    private func streamEndOccured(_ stream: Stream) {
        closeStream(stream)
        if stream == inputStream {
            eventsHandler?(.inputStreamClosed)
        } else if stream == outputStream {
            eventsHandler?(.outputStreamClosed)
        }
    }
}
