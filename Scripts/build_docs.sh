jazzy \
    --author "Noah Peeters" \
    --author_url "https://github.com/NoahPeeters" \
    --module SwiftCraft \
    --min-acl private \
    -e Sources/SwiftCraft/Network/Crypto/Encryption/SwCrypt.swift \
    --xcodebuild-arguments -project,SwiftCraft.xcodeproj,-scheme,"SwiftCraft iOS"
