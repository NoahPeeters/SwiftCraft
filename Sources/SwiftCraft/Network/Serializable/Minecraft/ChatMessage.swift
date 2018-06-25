//
//  ChatMessage.swift
//  SwiftCraft
//
//  Created by Noah Peeters on 23.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public struct ChatMessage: DeserializableDataType {
    public init<Buffer: ByteReadBuffer>(from buffer: Buffer) throws {
        let chatData = try Data(from: buffer)

        let jsonDecoder = JSONDecoder()
        message = try jsonDecoder.decode(ChatMessageComponent.self, from: chatData)
    }

    public let message: ChatMessageComponent
}

public enum ChatMessageComponent: Decodable {
    case text(text: String, options: Options)
    case translate(key: String, substitutions: [ChatMessageComponent]?, options: Options)
    case unknown(options: Options)

    public var options: Options {
        switch self {
        case let .text(_, options), let .translate(_, _, options), let .unknown(options):
            return options
        }
    }

    public struct Options: Decodable {
        // swiftlint:disable discouraged_optional_boolean
        public let bold: Bool?
        public let italic: Bool?
        public let underlined: Bool?
        public let strikethrough: Bool?
        public let obfuscated: Bool?
        // swiftlint:enable discouraged_optional_boolean

        public let color: String?
        public let insertion: String?
        public let extra: [ChatMessageComponent]?

        public static var empty: Options {
            return Options(bold: nil, italic: nil, underlined: nil,
                           strikethrough: nil, obfuscated: nil,
                           color: nil, insertion: nil, extra: nil)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case text = "text"
        case translationKey = "translate"
        case substitutions = "with"
    }

    public init(from coder: Decoder) throws {
        if let text = try? coder.singleValueContainer().decode(String.self) {
            self = .text(text: text, options: .empty)
        } else {
            let container = try coder.container(keyedBy: CodingKeys.self)
            if let text = try container.decodeIfPresent(String.self, forKey: .text) {
                self = try .text(text: text, options: Options(from: coder))
            } else if let translationKey = try container.decodeIfPresent(String.self, forKey: .translationKey) {
                self = try .translate(
                    key: translationKey,
                    substitutions: container.decodeIfPresent([ChatMessageComponent].self, forKey: .substitutions),
                    options: Options(from: coder))
            } else {
                self = try .unknown(options: Options(from: coder))
            }
        }
    }

    /// String representation of the component as it appears in the minecraft client.
    public var string: String {
        return stringWithoutSiblings + (options.extra ?? []).map {
            $0.string
        }.joined()
    }

    /// String represetnation of the the component without the siblings.
    private var stringWithoutSiblings: String {
        switch self {
        case let .text(text, _):
            return text
        case let .translate(key, substitutions, _):
            return MinecraftTranslations.string(withKey: key, substitutions: substitutions?.map { $0.string })
        case .unknown:
            return "<unknow message type>"
        }
    }
}
