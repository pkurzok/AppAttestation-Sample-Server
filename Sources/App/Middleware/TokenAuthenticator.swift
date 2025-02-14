//
//  File.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 16.01.25.
//

import JWT
import Vapor

struct TokenAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Vapor.Request) async throws {
        guard request.hasValidApiToken else {
            throw Abort(.unauthorized)
        }

        guard try await request.hasValidDeviceToken else {
            throw Abort(.unauthorized)
        }
    }
}

extension Vapor.Request {
    var hasValidApiToken: Bool {
        headers.first(name: "apiKey") == "HighlySecretAPIKey"
    }

    var hasValidDeviceToken: Bool {
        get async throws {
            guard let deviceToken = headers.first(name: "deviceToken") else {
                return false
            }

            return try await hasValidToken(deviceToken)
        }
    }

    func hasValidToken(_ token: String) async throws -> Bool {

        let jwtToken = try await generateJWT()
        let response = try await client.post("https://api.development.devicecheck.apple.com/v1/validate_device_token") {
            req in

            try req.content.encode(DeviceValidationRequest(deviceToken: token))

            req.headers.add(name: "Authorization", value: "Bearer \(jwtToken)")
        }

        logger.debug("Device Validation Response: \(response.description)")

        return response.status == .ok
    }

    func generateJWT() async throws -> String {

        let privateKey = try ES256PrivateKey(pem: p8)
        await application.jwt.keys.add(ecdsa: privateKey)

        let teamId = "99ED34GJ9X"  // Replace with your Apple Team ID
        let keyId = "8WT8LNYS6L"  // Replace with your Key ID
        let deviceCheckAudience = AudienceClaim(value: "apple")

        let payload = DeviceCheckPayload(
            iss: IssuerClaim(value: teamId),
            iat: IssuedAtClaim(value: Date()),
            exp: ExpirationClaim(value: Date().addingTimeInterval(60 * 60)),  // Token expires in 1 hour
            aud: deviceCheckAudience
        )

        return try await jwt.sign(payload, kid: .init(string: keyId))
    }
}

struct DeviceValidationRequest: Content {
    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
        case transactionId = "transaction_id"
        case timestamp = "timestamp"
    }

    let deviceToken: String
    let transactionId: String
    let timestamp: Int64

    init(
        deviceToken: String,
        transactionId: String = UUID().uuidString,
        timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    ) {
        self.deviceToken = deviceToken
        self.transactionId = transactionId
        self.timestamp = timestamp
    }
}

struct DeviceCheckPayload: JWTPayload {
    var iss: IssuerClaim
    var iat: IssuedAtClaim
    var exp: ExpirationClaim
    var aud: AudienceClaim

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.exp.verifyNotExpired()
    }
}

private let p8 =
    """
    -----BEGIN PRIVATE KEY-----
    PRIVATE KEY GOES HERE
    -----END PRIVATE KEY-----
    """
