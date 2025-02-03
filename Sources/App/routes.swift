import Crypto
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("challenge") { req async -> String in
        // Generate a random 16-byte value
        let randomBytes = [UInt8].random(count: 16)

        // Compute the SHA256 hash of the random bytes
        let hash = SHA256.hash(data: Data(randomBytes))

        // Convert the hash to a hex string
        let challenge = hash.map { String(format: "%02x", $0) }.joined()

        return challenge
    }

    try app.register(collection: SamplesController())
}
