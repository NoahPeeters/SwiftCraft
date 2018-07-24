//
//  Reactor+Reactive.swift
//  SwiftCraftReactive
//
//  Created by Noah Peeters on 02.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import SwiftCraft
import Result
import ReactiveSwift

extension MinecraftClient {
    /// Creates a signal producer for all packets.
    ///
    /// - Returns: A signal producer which will forward all received packets.
    public func packetsSignal() -> Signal<DeserializablePacket, NoError> {
        return Signal { observer, lifetime in
            let reactor = ReactivePacketReactor(observer: observer)
            let uuid = self.addReactor(reactor)

            lifetime.observeEnded { [weak self] in
                self?.removeReactor(with: uuid)
            }
        }
    }

    /// Creats a signal producer for all packets of a specific type.
    ///
    /// - Parameter _: The packet type to receive.
    /// - Returns: A signal producer which will forward all received packets of the given type.
    public func packetSignal<PacketType: DeserializablePacket>(_: PacketType.Type) -> Signal<PacketType, NoError> {
        return Signal { observer, lifetime in
            let reactor = ClosureReactor { packet, _ in
                observer.send(value: packet)
            }
            let uuid = self.addReactor(reactor)

            lifetime.observeEnded { [weak self] in
                self?.removeReactor(with: uuid)
            }
        }
    }
}

// MARK: - Private reactor.

private class ReactivePacketReactor: Reactor {
    private weak var observer: Signal<DeserializablePacket, NoError>.Observer?

    fileprivate init(observer: Signal<DeserializablePacket, NoError>.Observer) {
        self.observer = observer
    }

    fileprivate func didReceivedPacket(_ packet: DeserializablePacket, client: MinecraftClient) {
        observer?.send(value: packet)
    }
}
