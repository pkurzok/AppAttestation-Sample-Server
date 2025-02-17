//
//  AttestationController.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 17.02.25.
//

import AppAttest
import Vapor

struct AttestationController: RouteCollection {

    let appAttestStorage: AppAttestStorage
    let challengeStorage: ChallengeStorage

    func boot(routes: any Vapor.RoutesBuilder) throws {
        routes.get("challenge", use: challenge)
        routes.post("attestation", use: attestation)
        routes.post("assertion", use: assertion)
    }

    func challenge(req: Request) throws -> Challenge {
        challengeStorage.createChallenge()
    }

    func attestation(_ req: Request) throws -> Bool {
        let attestationRq = try req.content.decode(AttestationRequest.self)

        guard let challenge = challengeStorage.challenge(for: attestationRq.challengeID) else {
            req.logger.error("Missing ChallengeId")
            throw Abort(.badRequest)
        }

        let request = AppAttest.AttestationRequest(
            attestation: attestationRq.attestation,
            keyID: attestationRq.keyID
        )
        let appID = AppAttest.AppID(
            teamID: "99ED34GJ9X",
            bundleID: "com.peterkurzok.AppAttestationClient"
        )

        do {
            let result = try AppAttest.verifyAttestation(challenge: challenge, request: request, appID: appID)
            appAttestStorage.store(attestation: result, for: attestationRq.keyID)
            return true
        } catch {
            req.logger.error("Error verifying Attestation: \(error.localizedDescription)")
            throw Abort(.forbidden)
        }
    }

    func assertion(_ req: Request) throws -> Bool {
        let assertionRq = try req.content.decode(AssertionRequest.self)

        guard let challenge = challengeStorage.challenge(for: assertionRq.challengeID) else {
            req.logger.error("Missing ChallengeId")
            throw Abort(.badRequest)
        }

        guard let attestation = appAttestStorage.attestation(for: assertionRq.keyID) else {
            req.logger.error("No attestation for this KeyID found!")
            throw Abort(.badRequest)
        }

        let previousAssertion = appAttestStorage.assertion(for: assertionRq.keyID)

        let request = AppAttest.AssertionRequest(
            assertion: assertionRq.assertion,
            clientData: assertionRq.clientData,
            challenge: challenge
        )

        let appID = AppAttest.AppID(
            teamID: "99ED34GJ9X",
            bundleID: "com.peterkurzok.AppAttestationClient"
        )

        do {
            let result = try AppAttest.verifyAssertion(
                challenge: challenge,
                request: request,
                previousResult: previousAssertion,
                publicKey: attestation.publicKey,
                appID: appID
            )
            appAttestStorage.store(assertion: result, for: assertionRq.keyID)
            return true
        } catch {
            req.logger.error("Error verifying Assertion: \(error.localizedDescription)")
            throw Abort(.forbidden)
        }
    }
}
