//
//  TCPClient.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

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

/// A simple TCP client to send and receive tcp messages.
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

    /// Creates a new tcp client.
    ///
    /// - Parameters:
    ///   - host: The host to connect to.
    ///   - port: The port to connect to.
    public convenience init(host: String, port: Int) {
        self.init(host: host as CFString, port: UInt32(port))
    }

    /// Connects to the host and port of the client.
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
        inputStream!.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream!.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)

        // open
        inputStream!.open()
        outputStream!.open()
    }

    /// Closes the connection to the server.
    /// - Attention: The close function must be called on the same runloop as the connect function.
    public func close() {
        if let inputStream = inputStream {
            closeStream(inputStream)
        }

        if let outputStream = outputStream {
            closeStream(outputStream)
        }
    }

    /// Closes a stream and removes it from the current runloop.
    ///
    /// - Parameter stream: The stream to close.
    /// - Attention: The close function must be called on the same runloop as the connect function.
    private func closeStream(_ stream: Stream) {
        stream.close()
        stream.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
    }

    /// Sends the given bytes if the outout stream is open.
    ///
    /// - Parameter bytes: The bytes to send.
    public func send(bytes: ByteArray) {
        outputStream?.write(UnsafePointer<UInt8>(bytes), maxLength: bytes.count)
    }

    /// Sets the handler for all future events.
    ///
    /// - Parameter handler: The handler to use for future events.
    public func events(handler: ((TCPClientEvent) -> Void)?) {
        self.eventsHandler = handler
    }
}

extension TCPClient: StreamDelegate {
    /// Handels a incomming stream event.
    ///
    /// - Parameters:
    ///   - stream: The stream which received the event.
    ///   - eventCode: The code of the event.
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

    /// Handles space available in a steream buffer event.
    ///
    /// - Parameter stream: The stream which has space available.
    private func streamHasSpaceAvailable(_ stream: Stream) {
        if stream == inputStream {
            eventsHandler?(.inputStreamHasSpaceAvailable)
        } else if stream == outputStream {
            eventsHandler?(.outputStreamHasSpaceAvailable)
        }
    }

    /// Handels an event which indicates that the input buffer of a stream has new data.
    ///
    /// - Parameter stream: The stream which has bytes available.
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

    /// Handels an event which indicated that the steram was closed.
    ///
    /// - Parameter stream: The stream which was closed.
    private func streamEndOccured(_ stream: Stream) {
        closeStream(stream)
        if stream == inputStream {
            eventsHandler?(.inputStreamClosed)
        } else if stream == outputStream {
            eventsHandler?(.outputStreamClosed)
        }
    }
}
