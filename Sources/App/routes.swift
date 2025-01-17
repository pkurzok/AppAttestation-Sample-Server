import Vapor
import JWT

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: SamplesController())

    app.middleware.use(
        AppCheckAuthenticator(
            client: app.client,
            logger: app.logger
        )
    )
    app.middleware.use(TokenAuthenticator())
}
