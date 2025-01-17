//
//  AppCheckAuthenticator.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 17.01.25.
//

import JWT
import Vapor

final class AppCheckAuthenticator: AsyncRequestAuthenticator {

    private let client: Client
    private let logger: Logger

    private let jwkUrl = URI(string: "https://firebaseappcheck.googleapis.com/v1/jwks")
    private var keys = JWTKeyCollection()

    init(client: Client, logger: Logger) {
        self.client = client
        self.logger = logger

        Task {
            await fetchJwks()
        }
    }

    private func fetchJwks() async {
        // 1. Obtain the Firebase App Check Public Keys
        // Note: It is not recommended to hard code these keys as they rotate,
        // but you should cache them for up to 6 hours.

        do {
            let res = try await client.get(jwkUrl)
            let jwkRes = try res.content.decode(JWKResponse.self)

            for jwk in jwkRes.keys {
                try await keys.add(jwk: jwk)
            }

            logger.info("Added \(jwkRes.keys.count) Firebase JWKs")
        } catch {
            logger.error("Error fetching Firebase JWKs: \(error.localizedDescription)")
        }
    }

    func authenticate(request: Vapor.Request) async throws {
        guard let token = request.headers.first(name: "X-Firebase-AppCheck") else {
            throw Abort(.unauthorized)
        }

        let payload = try await keys.verify(token, as: AppCheckPayload.self)
        logger.info("Succesfull AppCheck Verification: \(payload)")
    }

    private struct JWKResponse: Content {
        let keys: [JWK]
    }

    private struct AppCheckPayload: JWTPayload {
        var sub: SubjectClaim
        var exp: ExpirationClaim
        var iss: String
        var aud: [String]

        func verify(using key: some JWTAlgorithm) throws {
            // 2. Verify the signature on the App Check token
            // payload, header = JWT.decode(token, nil, true, jwks: jwks, algorithms: 'RS256')

            // 3. Ensure the token's header uses the algorithm RS256
            // return unless header['alg'] == 'RS256'

            // 4. Ensure the token's header has type JWT
            // return unless header['typ'] == 'JWT'

            // 5. Ensure the token is issued by App Check
            guard iss == "https://firebaseappcheck.googleapis.com/753881955710" else {
                throw JWTError.generic(identifier: "iss", reason: "Unexpected issuer")
            }

            // 6. Ensure the token is not expired
            try self.exp.verifyNotExpired()

            // 7. Ensure the token's audience matches your project
            guard aud.contains("projects/753881955710") else {
                throw JWTError.generic(identifier: "aud", reason: "Unexpected audience")
            }

            // 8. The token's subject will be the app ID, you may optionally filter against
            // an allow list
        }
    }
}
