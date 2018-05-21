//
//  ReactiveTCPClient.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 21.05.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Result
import ReactiveSwift

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
public protocol ReactiveTCPClientProtocol {
    /// The type of the events signal
    typealias EventsSignal = Signal<TCPClientEvent, NoError>

    /// The type of the output signal
    typealias OutputSignal = Signal<ByteArray, NoError>

    /// Connects the client to its server.
    func connect()

    /// Closes the connection
    func close()

    /// The events signal.
    var events: EventsSignal { get }

    /// The observer for new messages to send
    var output: OutputSignal.Observer { get }

    /// The host to connect to.
    var host: CFString { get }

    /// The port to connect to
    var port: UInt32 { get }
}

public class ReactiveTCPClient: NSObject, ReactiveTCPClientProtocol {
    /// The underlying input stream.
    private var inputStream: InputStream?
    /// The underlying output stream.
    private var outputStream: OutputStream?

    /// The host to connect to.
    public let host: CFString

    /// The port to connect to
    public let port: UInt32

    public let events: EventsSignal
    private let eventsObserver: EventsSignal.Observer

    private let outputSignal: OutputSignal
    public let output: OutputSignal.Observer

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

        (events, eventsObserver) = EventsSignal.pipe()
        (outputSignal, output) = OutputSignal.pipe()

        super.init()

        outputSignal.observeValues { [weak self] bytes in
            self?.send(bytes: bytes)
        }
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
}

extension ReactiveTCPClient: StreamDelegate {
    public func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            streamOpened(stream)
        case .hasSpaceAvailable:
            streamHasSpaceAvailable(stream)
        case .hasBytesAvailable:
            streamHasBytesAvailable(stream)
        case .errorOccurred:
            eventsObserver.send(value: .unknownError)
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
            eventsObserver.send(value: .inputStreamOpened)
        } else if stream == outputStream {
            eventsObserver.send(value: .outputStreamOpened)
        }
    }

    private func streamHasSpaceAvailable(_ stream: Stream) {
        if stream == inputStream {
            eventsObserver.send(value: .inputStreamHasSpaceAvailable)
        } else if stream == outputStream {
            eventsObserver.send(value: .outputStreamHasSpaceAvailable)
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
                eventsObserver.send(value: .received(data: data))
            }
        }
    }

    private func streamEndOccured(_ stream: Stream) {
        closeStream(stream)
        if stream == inputStream {
            eventsObserver.send(value: .inputStreamClosed)
        } else if stream == outputStream {
            eventsObserver.send(value: .outputStreamClosed)
        }
    }
}
