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
    public func packetsSignal() -> Signal<DeserializablePacket, NoError> {
        return Signal { observer, lifetime in
            let reactor = ReactivePacketReactor(observer: observer)
            let uuid = self.addReactor(reactor)

            lifetime.observeEnded { [weak self] in
                self?.removeReactor(with: uuid)
            }
        }
    }

    public func packetSignal<PacketType: DeserializablePacket>(_ : PacketType.Type) -> Signal<PacketType, NoError> {
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

private class ReactivePacketReactor: Reactor {
    weak var observer: Signal<DeserializablePacket, NoError>.Observer?

    init(observer: Signal<DeserializablePacket, NoError>.Observer) {
        self.observer = observer
    }

    public func didReceivedPacket(_ packet: DeserializablePacket, client: MinecraftClient) throws {
        observer?.send(value: packet)
    }
}
