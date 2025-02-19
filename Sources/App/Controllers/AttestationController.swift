//
//  AttestationController.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 17.02.25.
//

import AppAttest
import Vapor

struct AttestationController: RouteCollection {

    let appAttestService: AppAttestService
    let challengeStorage: ChallengeStorage

    func boot(routes: any Vapor.RoutesBuilder) throws {
        routes.get("challenge", use: challenge)
        routes.post("attestation", use: attestation)
    }

    func challenge(req: Request) throws -> Challenge {
        challengeStorage.createChallenge()
    }

    func attestation(_ req: Request) throws -> Bool {
        let attestationRq = try req.content.decode(AttestationRequest.self)

        return try appAttestService.validate(
            attestationRq.attestation,
            keyID: attestationRq.keyID,
            challengeID: attestationRq.challengeID
        )
    }
}
