import Crypto
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(
        collection: AttestationController(
            appAttestStorage: app.appAttestStorage,
            challengeStorage: app.challengeStorage
        )
    )
    try app.register(collection: SamplesController())
}
