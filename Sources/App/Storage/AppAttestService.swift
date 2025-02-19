//
//  AppAttestService.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 18.02.25.
//

import AppAttest
import Vapor

struct AppAttestService {

    let appAttestStorage: AppAttestStorage
    let challengeStorage: ChallengeStorage
    let logger: Logger

    func validate(_ attestation: Data, keyID: Data, challengeID: UUID) throws -> Bool {
        guard let challenge = challengeStorage.challenge(for: challengeID) else {
            logger.error("Missing ChallengeId")
            throw Abort(.badRequest)
        }

        let request = AppAttest.AttestationRequest(
            attestation: attestation,
            keyID: keyID
        )
        let appID = AppAttest.AppID(
            teamID: "99ED34GJ9X",
            bundleID: "com.peterkurzok.AppAttestationClient"
        )

        do {
            let result = try AppAttest.verifyAttestation(challenge: challenge, request: request, appID: appID)
            appAttestStorage.store(attestation: result, for: keyID)
            return true
        } catch {
            logger.error("Error verifying Attestation: \(error.localizedDescription)")
            throw Abort(.forbidden)
        }
    }

    func validate(_ assertion: Data, clientData: Data, challengeID: UUID, keyID: Data) throws -> Bool {
        guard let challenge = challengeStorage.challenge(for: challengeID) else {
            logger.error("Missing ChallengeId")
            throw Abort(.badRequest)
        }

        guard let attestation = appAttestStorage.attestation(for: keyID) else {
            logger.error("No attestation for this KeyID found!")
            throw Abort(.badRequest)
        }

        let previousAssertion = appAttestStorage.assertion(for: keyID)

        let request = AppAttest.AssertionRequest(
            assertion: assertion,
            clientData: clientData,
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
            appAttestStorage.store(assertion: result, for: keyID)
            return true
        } catch {
            logger.error("Error verifying Assertion: \(error.localizedDescription)")
            throw Abort(.forbidden)
        }
    }
}

extension Application {
    var appAttestService: AppAttestService {
        .init(appAttestStorage: .shared, challengeStorage: .shared, logger: logger)
    }
}
