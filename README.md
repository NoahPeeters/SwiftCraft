# SwiftCraft

[![Build Status](https://travis-ci.com/NoahPeeters/SwiftCraft.svg?token=HsyqpG6RFpdTFfmvYcAF&branch=master)](https://travis-ci.com/NoahPeeters/SwiftCraft)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20Linux-909090.svg?style=flat)](https://github.com/Carthage/Carthage)

SwiftCraft is a simple library to connect to and communicate with a Minecraft server.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Carthage](#carthage)
  - [Swift Package Manager](#swift-package-manager)
- [Usage](#usage)

## Features

- User login
- Connect in online and offline mode
- Packet encoding and decoding
- Packet Compression Support
- Packet Encryption Support
- Simple to use type safe interface

## Requirements

- iOS 9.0+ / macOS 10.10+ / tvOS 9.0+ / Linux
- Xcode 9.3+
- Swift 4.1+

The library will work with a configuration from above. It might also work with older versions but this is not testet.

## Installation

### Carthage

To integrate SwiftCraft into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "NoahPeeters/SwiftCraft" ~> 1.0
```

### Swift Package Manager

To integrate SwiftCraft into your project using Swift Package Manager, specify it in your `Package.swift` under `dependencies`:

```swift
dependencies: [
    .package(url: "https://github.com/NoahPeeters/SwiftCraft.git", from: "1.0.0")
]
```

## Usage

This is a simple example which will print all chat messages.

```swift
// Create a client.
let client = MinecraftClient(
    tcpClient: TCPClient(host: "localhost", port: 25565),
    packetLibrary: DefaultPacketLibrary(),
    sessionServerService: OfflineSessionService(username: "Username"))

// Add a reactor to handle keepalive etc. packets.
_ = client.addReactor(MinecraftClient.essentialReactors())

// Add a reactor which will print all chat messages.
_ = client.addReactor(MinecraftClient.chatPrintReactor())

// Connect to the server.
if client.connectAndLogin() {
    print("Connected.")
} else {
    print("Connection failed.")
}
```
